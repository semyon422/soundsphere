local class = require("class")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")
local Chartfile = require("sea.chart.Chartfile")
local ChartplaysAccess = require("sea.chart.access.ChartplaysAccess")
local Chartkey = require("sea.chart.Chartkey")
local ComputeContext = require("sea.compute.ComputeContext")
local ReplayBase = require("sea.replays.ReplayBase")

---@class sea.Chartplays
---@operator call: sea.Chartplays
local Chartplays = class()

---@param charts_repo sea.ChartsRepo
---@param chartfiles_repo sea.ChartfilesRepo
---@param compute_data_loader sea.ComputeDataLoader
---@param leaderboards sea.Leaderboards
---@param charts_storage sea.IKeyValueStorage
---@param replays_storage sea.IKeyValueStorage
function Chartplays:new(
	charts_repo,
	chartfiles_repo,
	compute_data_loader,
	leaderboards,
	charts_storage,
	replays_storage
)
	self.charts_repo = charts_repo
	self.chartfiles_repo = chartfiles_repo
	self.compute_data_loader = compute_data_loader
	self.leaderboards = leaderboards
	self.charts_storage = charts_storage
	self.replays_storage = replays_storage
	self.chartplays_access = ChartplaysAccess()
end

---@return sea.Chartplay[]
function Chartplays:getChartplays()
	return self.charts_repo:getChartplays()
end

---@param id integer
---@return sea.Chartplay?
function Chartplays:getChartplay(id)
	return self.charts_repo:getChartplay(id)
end

---@param user sea.User
---@param time integer
---@param compute_data_loader sea.ComputeDataLoader
---@param chartplay_values sea.Chartplay
---@param chartdiff_values sea.Chartdiff
---@return sea.Chartplay?
---@return string?
function Chartplays:submit(user, time, compute_data_loader, chartplay_values, chartdiff_values)
	local charts_repo = self.charts_repo
	local chartfiles_repo = self.chartfiles_repo

	local can, err = self.chartplays_access:canSubmit(user)
	if not can then
		return nil, "can submit: " .. err
	end

	local chartplay = charts_repo:getChartplayByReplayHash(chartplay_values.replay_hash)
	if not chartplay then
		assert(not chartplay_values.id)
		chartplay_values.user_id = user.id
		chartplay_values.submitted_at = time
		chartplay_values.computed_at = time
		chartplay_values.compute_state = "new"

		chartplay = charts_repo:createChartplay(chartplay_values)
	end

	assert(chartplay_values:equalsChartplay(chartplay))

	local save_chart, save_replay = false, false

	local chart_file_data, err = self.compute_data_loader:requireChart(chartplay.hash)
	if not chart_file_data then
		chart_file_data, err = compute_data_loader:requireChart(chartplay.hash)
		if not chart_file_data then
			return nil, "require chart: " .. err
		end
		save_chart = true
	end

	local chartfile_name = chart_file_data.name
	local chartfile_data = chart_file_data.data

	local replay_and_data, err = self.compute_data_loader:requireReplay(chartplay.replay_hash)
	if not replay_and_data then
		replay_and_data, err = compute_data_loader:requireReplay(chartplay.replay_hash)
		if not replay_and_data then
			return nil, "require replay: " .. err
		end
		save_replay = true
	end

	local replay = replay_and_data.replay
	local replay_data = replay_and_data.data

	local eq, err = replay:equalsChartplayBase(chartplay)
	if not eq then
		return nil, "chartplay base of replay differs: " .. err
	end

	local eq, err = replay:equalsChartmetaKey(chartplay)
	if not eq then
		return nil, "chartmeta key of replay differs: " .. err
	end

	---@type sea.Chartfile
	local chartfile

	if save_chart then
		chartfile = chartfiles_repo:getChartfileByHash(chartplay.hash)
		if not chartfile then
			local chartfile_values = Chartfile()
			chartfile_values.hash = chartplay.hash
			chartfile_values.creator_id = user.id
			chartfile_values.compute_state = "new"
			chartfile_values.computed_at = time
			chartfile_values.submitted_at = time
			chartfile_values.name = chartfile_name
			chartfile_values.size = #chartfile_data
			chartfile = chartfiles_repo:createChartfile(chartfile_values)
		end

		local ok, err = self.charts_storage:set(chartplay.hash, chartfile_data)
		if not ok then
			return nil, "charts storage set: " .. err
		end
	end

	if save_replay then
		local ok, err = self.replays_storage:set(chartplay.replay_hash, replay_data)
		if not ok then
			return nil, "replays storage set: " .. err
		end
	end

	chartfile = assert(chartfiles_repo:getChartfileByHash(chartplay.hash))

	local ctx = ComputeContext()

	local chart_chartmeta, err = ctx:fromFileData(
		chart_file_data.name,
		chart_file_data.data,
		chartplay.index
	)

	if not chart_chartmeta then
		chartplay.compute_state = "invalid"
		chartplay.computed_at = time
		charts_repo:updateChartplay(chartplay)
		return nil, "from file data: " .. err
	end

	local chartmeta = charts_repo:createUpdateChartmeta(chart_chartmeta.chartmeta, time)

	local timings = chartplay.timings or chartmeta.timings
	if not timings then
		chartplay.compute_state = "invalid"
		chartplay.computed_at = time
		charts_repo:updateChartplay(chartplay)
		return nil, "missing timings"
	end

	if #chartplay.modifiers > 0 or chartplay.rate ~= 1 then
		-- create default chartdiff
		local default_chartkey = Chartkey()
		default_chartkey.hash = chartplay.hash
		default_chartkey.index = chartplay.index
		default_chartkey.rate = 1
		default_chartkey.modifiers = {}
		default_chartkey.mode = "mania"

		local default_chartdiff = charts_repo:getChartdiffByChartkey(default_chartkey)
		if not default_chartdiff then
			local chartdiff = ctx:computeBase(ReplayBase())
			chartdiff = charts_repo:createUpdateChartdiff(chartdiff, time)
		end
	end

	---@type sea.Chartdiff
	local computed_chartdiff

	if chartplay.custom then
		computed_chartdiff = chartdiff_values
		computed_chartdiff.custom_user_id = user.id
	else
		ctx:applyModifierReorder(replay)

		computed_chartdiff = ctx:computeBase(replay)

		local chartplay_computed, err = ctx:computeReplay(replay)
		if not chartplay_computed then
			chartplay.compute_state = "invalid"
			chartplay.computed_at = time
			charts_repo:updateChartplay(chartplay)
			return nil, "compute: " .. err
		end

		local eq, err = chartplay:equalsComputed(chartplay_computed)
		if not eq then
			chartplay.compute_state = "invalid"
			chartplay.computed_at = time
			charts_repo:updateChartplay(chartplay)
			return nil, "computed chartplay differs: " .. err
		end

		local eq, err = chartdiff_values:equalsComputed(computed_chartdiff)
		if not eq then
			chartplay.compute_state = "invalid"
			chartplay.computed_at = time
			charts_repo:updateChartplay(chartplay)
			return nil, "computed values differs: " .. err
		end
	end

	local subtimings = chartplay.subtimings

	if timings.name ~= "arbitrary" then
		local timing_values = TimingValuesFactory:get(timings, subtimings)
		if not timing_values then
			chartplay.compute_state = "invalid"
			chartplay.computed_at = time
			charts_repo:updateChartplay(chartplay)
			return nil, "timing values differs"
		end
	end

	chartplay.compute_state = "valid"
	chartplay.computed_at = time
	charts_repo:updateChartplay(chartplay)

	local chartdiff = charts_repo:createUpdateChartdiff(computed_chartdiff, time)

	if not chartplay.custom then
		self.leaderboards:addChartplay(chartplay)
	end

	return chartplay
end

return Chartplays
