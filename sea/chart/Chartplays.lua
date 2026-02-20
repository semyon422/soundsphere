local class = require("class")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")
local Chartfile = require("sea.chart.Chartfile")
local ChartplaysAccess = require("sea.chart.access.ChartplaysAccess")
local ChartdiffKey = require("sea.chart.ChartdiffKey")
local ComputeContext = require("sea.compute.ComputeContext")
local ReplayBase = require("sea.replays.ReplayBase")

---@class sea.Chartplays
---@operator call: sea.Chartplays
local Chartplays = class()

---@param charts_repo sea.ChartsRepo
---@param chartfiles_repo sea.ChartfilesRepo
---@param compute_data_loader sea.ComputeDataLoader
---@param charts_storage sea.IKeyValueStorage
---@param replays_storage sea.IKeyValueStorage
function Chartplays:new(
	charts_repo,
	chartfiles_repo,
	compute_data_loader,
	charts_storage,
	replays_storage
)
	self.charts_repo = charts_repo
	self.chartfiles_repo = chartfiles_repo
	self.compute_data_loader = compute_data_loader
	self.charts_storage = charts_storage
	self.replays_storage = replays_storage
	self.chartplays_access = ChartplaysAccess()
end

---@param user sea.User
---@param replay_hash string
---@return string?
---@return string?
function Chartplays:getReplayFile(user, replay_hash)
	if user:isAnon() then
		return nil, "anon user"
	end
	return self.replays_storage:get(replay_hash)
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

---@param chartmeta_key sea.ChartmetaKey
---@return sea.Chartplay[]?
---@return string?
function Chartplays:getChartplaysForChartmeta(chartmeta_key)
	return self.charts_repo:getChartplaysForChartmeta(chartmeta_key)
end

---@param chartdiff_key sea.ChartdiffKey
---@return sea.Chartplay[]?
---@return string?
function Chartplays:getChartplaysForChartdiff(chartdiff_key)
	return self.charts_repo:getChartplaysForChartdiff(chartdiff_key)
end

---@param user sea.User
---@param chartmeta_key sea.ChartmetaKey
---@return sea.Chartplay[]?
---@return string?
function Chartplays:getBestChartplaysForChartmeta(user, chartmeta_key)
	if user:isAnon() then
		return nil, "anon user"
	end
	return self.charts_repo:getBestChartplaysForChartmeta(chartmeta_key)
end

---@param user sea.User
---@param chartdiff_key sea.ChartdiffKey
---@return sea.Chartplay[]?
---@return string?
function Chartplays:getBestChartplaysForChartdiff(user, chartdiff_key)
	if user:isAnon() then
		return nil, "anon user"
	end
	return self.charts_repo:getBestChartplaysForChartdiff(chartdiff_key)
end

---@param user_id integer
---@param time integer
---@param chartplay_values sea.Chartplay
---@return sea.Chartplay
function Chartplays:getCreateChartplay(user_id, time, chartplay_values)
	local charts_repo = self.charts_repo

	local chartplay = charts_repo:getChartplayByReplayHash(chartplay_values.replay_hash)
	if not chartplay then
		assert(not chartplay_values.id)
		chartplay_values.user_id = user_id
		chartplay_values.submitted_at = time
		chartplay_values.computed_at = time
		chartplay_values.compute_state = "new"

		chartplay = charts_repo:createChartplay(chartplay_values)
	end

	-- db check
	assert(chartplay_values:equalsChartplay(chartplay))

	return chartplay
end

---@param compute_data_loader sea.ComputeDataLoader
---@param chartplay sea.Chartplay
---@return sea.Replay?
---@return string?
function Chartplays:loadReplay(compute_data_loader, chartplay)
	local save_replay = false

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

	if save_replay then
		local ok, err = self.replays_storage:set(chartplay.replay_hash, replay_data)
		if not ok then
			return nil, "replays storage set: " .. err
		end
	end

	return replay
end

---@param user_id integer
---@param time integer
---@param compute_data_loader sea.ComputeDataLoader
---@param hash string
function Chartplays:loadChart(user_id, time, compute_data_loader, hash)
	local chartfiles_repo = self.chartfiles_repo

	local save_chart = false

	local chart_file_data, err = self.compute_data_loader:requireChart(hash)
	if not chart_file_data then
		chart_file_data, err = compute_data_loader:requireChart(hash)
		if not chart_file_data then
			return nil, "require chart: " .. err
		end
		save_chart = true
	end

	local chartfile_name = chart_file_data.name
	local chartfile_data = chart_file_data.data

	if save_chart then
		local ok, err = self.charts_storage:set(hash, chartfile_data)
		if not ok then
			return nil, "charts storage set: " .. err
		end
	end

	local chartfile = chartfiles_repo:getChartfileByHash(hash)
	if not chartfile then
		local chartfile_values = Chartfile()
		chartfile_values.hash = hash
		chartfile_values.creator_id = user_id
		chartfile_values.compute_state = "new"
		chartfile_values.computed_at = time
		chartfile_values.submitted_at = time
		chartfile_values.name = chartfile_name
		chartfile_values.size = #chartfile_data
		chartfile = chartfiles_repo:createChartfile(chartfile_values)
	end

	return chart_file_data
end

---@param user sea.User
---@param time integer
---@param compute_data_loader sea.ComputeDataLoader
---@param chartplay_values sea.Chartplay
---@param chartdiff_values sea.Chartdiff
---@return sea.ComputeContext?
---@return string?
function Chartplays:submit(user, time, compute_data_loader, chartplay_values, chartdiff_values)
	if user:isAnon() then
		return nil, "anon user"
	end

	local charts_repo = self.charts_repo

	local last_chartplay = charts_repo:getRecentChartplays(user.id, 1)

	local can, err = self.chartplays_access:canSubmit(user, time, last_chartplay[1])
	if not can then
		return nil, "can submit: " .. err
	end

	-- It is important to save the submitted chartplay early, even before 
	-- validation/processing. This ensures we have a record of the player's 
	-- attempt and result, which can be re-processed or recovered later 
	-- if subsequent steps (like chart retrieval or rank calculation) fail.
	local chartplay = self:getCreateChartplay(user.id, time, chartplay_values)

	local ctx, err = self:processSubmit(user, time, compute_data_loader, chartplay, chartdiff_values)
	if not ctx then
		chartplay.compute_state = "invalid"
		chartplay.computed_at = time
		charts_repo:updateChartplay(chartplay)
		return nil, err
	end

	chartplay.compute_state = "valid"
	chartplay.computed_at = time
	charts_repo:updateChartplay(chartplay)

	return ctx
end

---@param user sea.User
---@param time integer
---@param compute_data_loader sea.ComputeDataLoader
---@param chartplay sea.Chartplay
---@param chartdiff_values sea.Chartdiff
---@return sea.ComputeContext?
---@return string?
function Chartplays:processSubmit(user, time, compute_data_loader, chartplay, chartdiff_values)
	local charts_repo = self.charts_repo

	local replay, err = self:loadReplay(compute_data_loader, chartplay)
	if not replay then
		return nil, "load replay: " .. err
	end

	local chart_file_data, err = self:loadChart(user.id, time, compute_data_loader, chartplay.hash)
	if not chart_file_data then
		return nil, "load chart: " .. err
	end

	local ctx = ComputeContext()
	ctx.chartplay = chartplay

	local chart_chartmeta, err = ctx:fromFileData(
		chart_file_data.name,
		chart_file_data.data,
		chartplay.index
	)

	if not chart_chartmeta then
		return nil, "from file data: " .. err
	end

	local chartmeta = charts_repo:createUpdateChartmeta(chart_chartmeta.chartmeta, time)

	local timings = chartplay.timings or chartmeta.timings
	if not timings then
		return nil, "missing timings"
	end

	if timings.name ~= "arbitrary" then
		local timing_values = TimingValuesFactory:get(timings, chartplay.subtimings)
		if not timing_values then
			return nil, "invalid timings-subtimings pair"
		elseif not timing_values:equals(replay.timing_values) then
			return nil, "timing values differs"
		end
	end

	if #chartplay.modifiers > 0 or chartplay.rate ~= 1 then
		-- create default chartdiff
		local default_chartdiff_key = ChartdiffKey()
		default_chartdiff_key.hash = chartplay.hash
		default_chartdiff_key.index = chartplay.index
		default_chartdiff_key.rate = 1
		default_chartdiff_key.modifiers = {}
		default_chartdiff_key.mode = "mania"

		local default_chartdiff = charts_repo:getChartdiffByChartdiffKey(default_chartdiff_key)
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

		-- MSD is inconsistent for some reason
		-- Remove it from compare keys

		local eq, err = chartdiff_values:equalsComputed(computed_chartdiff, true)
		if not eq then
			-- return nil, "computed chartdiff differs: " .. err
		end

		local chartplay_computed, err = ctx:computeReplay(replay)
		if not chartplay_computed then
			return nil, "compute: " .. err
		end

		local eq, err = chartplay:equalsComputed(chartplay_computed, true)
		if not eq then
			-- return nil, "computed chartplay differs: " .. err
		end

		-- Use computed MSD
		chartplay:importChartplayComputed(chartplay_computed)
	end

	charts_repo:createUpdateChartdiff(computed_chartdiff, time)

	return ctx
end

return Chartplays
