local class = require("class")
local valid = require("valid")
local math_util = require("math_util")
local Chartplay = require("sea.chart.Chartplay")
local Chartfile = require("sea.chart.Chartfile")
local ComputeContext = require("sea.compute.ComputeContext")
local ChartplayComputer = require("sea.compute.ChartplayComputer")
local ComputeDataProvider = require("sea.compute.ComputeDataProvider")
local ComputeDataLoader = require("sea.compute.ComputeDataLoader")
local TableStorage = require("sea.chart.storage.TableStorage")
local ReplayBase = require("sea.replays.ReplayBase")
local ChartfilesRepo = require("sea.chart.repos.ChartfilesRepo")
local simplify_notechart = require("libchart.simplify_notechart")
local ReplayModel = require("sphere.models.ReplayModel")

local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")

---@class sea.FakeClient
---@operator call: sea.FakeClient
local FakeClient = class()

---@param accuracy number
---@param miss_ratio integer
function FakeClient:new(accuracy, miss_ratio)
	self.accuracy = accuracy
	self.miss_ratio = miss_ratio

	self.computeContext = ComputeContext()
	self.replayBase = ReplayBase()
	self.replayModel = ReplayModel()
	self.chartplayComputer = ChartplayComputer()

	local db = ServerSqliteDatabase(LjsqliteDatabase())
	db.path = ":memory:"
	db:open()

	local models = db.models

	self.chartfiles_repo = ChartfilesRepo(models)
	self.charts_storage = TableStorage()
	self.replays_storage = TableStorage()

	self.compute_data_provider = ComputeDataProvider(self.chartfiles_repo, self.charts_storage, self.replays_storage)
	self.compute_data_loader = ComputeDataLoader(self.compute_data_provider)
end

---@param chart ncdk2.Chart
---@param accuracy number
---@param miss_ratio integer?
---@return sea.ReplayEvent[]
function FakeClient:createFakeEvents(chart, accuracy, miss_ratio)
	miss_ratio = miss_ratio or math.huge

	---@type sea.ReplayEvent[]
	local events = {}

	math.randomseed(0)

	local notes = simplify_notechart(chart, {"tap"})
	for i, note in ipairs(notes) do
		if i % miss_ratio ~= 0 then
			local dt = math_util.nrandom() * accuracy
			local press_time = math.floor((note.time + dt) * 1024) / 1024
			local release_time = math.floor((press_time + 0.05) * 1024) / 1024
			table.insert(events, {press_time, note.column, true})
			table.insert(events, {release_time, note.column, false})
		end
	end

	table.sort(events, function(a, b)
		if a[1] == b[1] then
			return a[2] < b[2]
		end
		return a[1] < b[1]
	end)

	return events
end

---@param chartfile_name string
---@param chartfile_data string
---@param index integer
---@param created_at integer
---@param pause_count integer
---@param auto_timings boolean
function FakeClient:play(chartfile_name, chartfile_data, index, created_at, pause_count, auto_timings)
	local computeContext = self.computeContext
	local replayBase = self.replayBase
	local replayModel = self.replayModel

	local chart_chartmeta = assert(computeContext:fromFileData(chartfile_name, chartfile_data, index))
	local chart, chartmeta = chart_chartmeta.chart, chart_chartmeta.chartmeta

	computeContext:computeBase(replayBase)

	local events = self:createFakeEvents(chart, self.accuracy, self.miss_ratio)
	replayModel.events = events

	local replay, replay_data, replay_hash = replayModel:createReplay(
		replayBase,
		chartmeta,
		created_at,
		pause_count,
		auto_timings
	)

	self.chartplayComputer:computeFromContext(computeContext, replay)
	local ret = assert(self.chartplayComputer:computeFromContext(computeContext, replay))

	local chartplay = Chartplay()

	chartplay:importChartmetaKey(chartmeta)
	chartplay:importChartplayBase(replay)
	chartplay:importChartplayComputed(ret.chartplay_computed)

	chartplay.replay_hash = replay_hash
	chartplay.pause_count = pause_count
	chartplay.created_at = created_at

	assert(valid.format(chartplay:validate()))

	self.computeContext.chartplay = chartplay

	if not self.chartfiles_repo:getChartfileByHash(chartplay.hash) then
		local chartfile = Chartfile()
		chartfile.hash = chartplay.hash
		chartfile.name = chartfile_name
		chartfile.size = #chartfile_data
		chartfile.compute_state = "valid"
		chartfile.computed_at = created_at
		chartfile.creator_id = 1
		chartfile.submitted_at = created_at

		self.chartfiles_repo:createChartfile(chartfile)

		self.charts_storage:set(chartplay.hash, chartfile_data)
	end

	self.replays_storage:set(replay_hash, replay_data)

	return {
		chartplay = chartplay,
		chartdiff = ret.chartdiff,
		chartmeta = ret.chartmeta,
		replay = replay,
		replay_hash = replay_hash,
		replay_data = replay_data,
	}
end

return FakeClient
