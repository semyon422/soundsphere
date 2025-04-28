local class = require("class")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")
local Chartfile = require("sea.chart.Chartfile")
local ChartplaysAccess = require("sea.chart.access.ChartplaysAccess")

---@class sea.Chartplays
---@operator call: sea.Chartplays
local Chartplays = class()

---@param charts_repo sea.IChartsRepo
---@param chartfiles_repo sea.IChartfilesRepo
---@param chartplay_computer sea.IChartplayComputer
---@param compute_data_loader sea.ComputeDataLoader
---@param leaderboards sea.Leaderboards
---@param charts_storage sea.IKeyValueStorage
---@param replays_storage sea.IKeyValueStorage
function Chartplays:new(
	charts_repo,
	chartfiles_repo,
	chartplay_computer,
	compute_data_loader,
	leaderboards,
	charts_storage,
	replays_storage
)
	self.charts_repo = charts_repo
	self.chartfiles_repo = chartfiles_repo
	self.chartplay_computer = chartplay_computer
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
	local can, err = self.chartplays_access:canSubmit(user)
	if not can then
		return nil, "can submit: " .. err
	end

	local chartplay = self.charts_repo:getChartplayByReplayHash(chartplay_values.replay_hash)
	if not chartplay then
		chartplay_values.id = nil
		chartplay_values.user_id = user.id
		chartplay_values.submitted_at = time
		chartplay_values.compute_state = "new"

		chartplay = self.charts_repo:createChartplay(chartplay_values)
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
		chartfile = self.chartfiles_repo:getChartfileByHash(chartplay.hash)
		if not chartfile then
			local chartfile_values = Chartfile()
			chartfile_values.hash = chartplay.hash
			chartfile_values.creator_id = user.id
			chartfile_values.compute_state = "new"
			chartfile_values.submitted_at = time
			chartfile_values.name = chartfile_name
			chartfile_values.size = #chartfile_data
			chartfile = self.chartfiles_repo:createChartfile(chartfile_values)
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

	chartfile = assert(self.chartfiles_repo:getChartfileByHash(chartplay.hash))

	---@type sea.Chartdiff
	local computed_chartdiff
	---@type sea.Chartmeta
	local computed_chartmeta

	if chartplay.custom then
		computed_chartdiff = chartdiff_values
		computed_chartdiff.custom_user_id = user.id

		computed_chartmeta, err = self.chartplay_computer:computeChartmeta(chartfile.name, chartfile_data, chartplay.index)
		if not computed_chartmeta then
			chartplay.compute_state = "invalid"
			chartplay.computed_at = time
			self.charts_repo:updateChartplay(chartplay)
			return nil, "compute chartmeta: " .. err
		end
	else
		local ret, err = self.chartplay_computer:compute(
			chartfile.name, chartfile_data, chartplay.index, replay
		)
		if not ret then
			chartplay.compute_state = "invalid"
			chartplay.computed_at = time
			self.charts_repo:updateChartplay(chartplay)
			return nil, "compute: " .. err
		end

		computed_chartdiff = ret.chartdiff
		computed_chartmeta = ret.chartmeta

		local eq, err = chartplay:equalsComputed(ret.chartplay_computed)
		if not eq then
			chartplay.compute_state = "invalid"
			chartplay.computed_at = time
			self.charts_repo:updateChartplay(chartplay)
			return nil, "computed chartplay differs: " .. err
		end

		local eq, err = chartdiff_values:equalsComputed(computed_chartdiff)
		if not eq then
			return nil, "computed values differs: " .. err
		end
	end

	local timings = chartplay.timings or computed_chartmeta.timings
	if not timings then
		return nil, "missing timings"
	end

	local subtimings = chartplay.subtimings

	if timings.name ~= "arbitrary" then
		local timing_values = TimingValuesFactory:get(timings, subtimings)
		if not timing_values then
			chartplay.compute_state = "invalid"
			chartplay.computed_at = time
			self.charts_repo:updateChartplay(chartplay)
			return nil, "timing values differs"
		end
	end

	chartplay.compute_state = "valid"
	chartplay.computed_at = time
	self.charts_repo:updateChartplay(chartplay)

	local chartdiff = self.charts_repo:getChartdiffByChartkey(computed_chartdiff)
	if not chartdiff then
		self.charts_repo:createChartdiff(computed_chartdiff)
	elseif not chartdiff:equalsComputed(computed_chartdiff) then
		computed_chartdiff.id = chartdiff.id
		self.charts_repo:updateChartdiff(computed_chartdiff)
		-- add a note on chartdiff page about this change
	end

	local chartmeta = self.charts_repo:getChartmetaByHashIndex(computed_chartmeta.hash, computed_chartmeta.index)
	if not chartmeta then
		self.charts_repo:createChartmeta(computed_chartmeta)
	elseif not chartmeta:equalsComputed(computed_chartmeta) then
		computed_chartmeta.id = chartmeta.id
		self.charts_repo:updateChartmeta(computed_chartmeta)
		-- add a note on chartmeta page about this change
	end

	if not chartplay.custom then
		self.leaderboards:addChartplay(chartplay)
	end

	return chartplay
end

return Chartplays
