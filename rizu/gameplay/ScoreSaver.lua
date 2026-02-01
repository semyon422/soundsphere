local class = require("class")
local valid = require("valid")
local table_util = require("table_util")
local Chartplay = require("sea.chart.Chartplay")

---@class rizu.ScoreSaver
---@operator call: rizu.ScoreSaver
local ScoreSaver = class()

---@param fs fs.IFilesystem
---@param rhythm_engine rizu.RhythmEngine
---@param cacheModel sphere.CacheModel
---@param configModel sphere.ConfigModel
---@param seaClient sphere.SeaClient
---@param replayBase sea.ReplayBase
---@param computeContext sea.ComputeContext
function ScoreSaver:new(
	fs,
	rhythm_engine,
	cacheModel,
	configModel,
	seaClient,
	replayBase,
	computeContext
)
	self.fs = fs
	self.rhythm_engine = rhythm_engine
	self.cacheModel = cacheModel
	self.configModel = configModel
	self.seaClient = seaClient
	self.replayBase = replayBase
	self.computeContext = computeContext
end

function ScoreSaver:saveScore()
	local rhythm_engine = self.rhythm_engine
	local pause_counter = rhythm_engine.pause_counter
	local scoreEngine = rhythm_engine.score_engine
	local replayBase = self.replayBase
	local computeContext = self.computeContext

	local chartmeta = assert(computeContext.chartmeta)
	local created_at = os.time()

	local replay, replay_hash = self.replayModel:saveReplay(
		replayBase,
		chartmeta,
		created_at,
		pause_counter.count
	)

	local chartdiff = assert(computeContext.chartdiff)
	local chartdiff_copy = setmetatable(table_util.deepcopy(chartdiff), getmetatable(chartdiff))

	chartdiff = self.cacheModel.chartsRepo:createUpdateChartdiff(chartdiff, created_at)

	local chartplay = Chartplay()

	local chartplay_computed = rhythm_engine:getChartplayComputed()

	chartplay:importChartplayBase(replay)
	chartplay:importChartplayComputed(chartplay_computed)

	chartplay.hash = chartmeta.hash
	chartplay.index = chartmeta.index

	chartplay.replay_hash = replay_hash
	chartplay.pause_count = pause_counter.count
	chartplay.created_at = created_at

	assert(valid.format(chartplay:validate()))
	local chartplay_copy = setmetatable(table_util.deepcopy(chartplay), Chartplay)

	chartplay.user_id = 1
	chartplay.compute_state = "valid"
	chartplay.computed_at = created_at
	chartplay.submitted_at = created_at

	local _chartplay = self.cacheModel.chartsRepo:createChartplay(chartplay)
	computeContext.chartplay = _chartplay

	local function submit()
		if not self.seaClient.connected then
			return
		end

		local base = scoreEngine.scores.base
		if base.hitCount / base.notesCount < 0.5 then
			print("not submitted")
			return
		end

		print("submit")
		local ok, err = self.seaClient.remote.submission:submitChartplay(chartplay_copy, chartdiff_copy)
		print("got", ok, err)
		if ok then
			print(require("stbl").encode(ok))
		else
			print("dumping events")
			local data = require("string.buffer").encode(self.rhythm_engine.score_engine.events)
			self.fs:write("events.bin", data)
		end
	end

	coroutine.wrap(function()
		local ok, err = xpcall(submit, debug.traceback)
		if not ok then
			print("submit error", err)
		end
	end)()

	local config = self.configModel.configs.select
	config.select_chartplay_id = config.chartplay_id
	config.chartplay_id = _chartplay.id
end

return ScoreSaver
