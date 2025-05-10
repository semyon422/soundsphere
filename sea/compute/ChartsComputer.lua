local class = require("class")
local ReplayBase = require("sea.replays.ReplayBase")
local Chartkey = require("sea.chart.Chartkey")
local ComputeContext = require("sea.compute.ComputeContext")

---@class sea.ChartsComputer
---@operator call: sea.ChartsComputer
local ChartsComputer = class()

---@param compute_data_loader sea.ComputeDataLoader
---@param charts_repo sea.ChartsRepo
function ChartsComputer:new(compute_data_loader, charts_repo)
	self.compute_data_loader = compute_data_loader
	self.charts_repo = charts_repo
end

---@param chartplay sea.Chartplay
---@return {chartplay_computed: sea.ChartplayComputed, chartdiff: sea.Chartdiff, chartmeta: sea.Chartmeta}?
---@return string?
function ChartsComputer:computeChartplay(chartplay)
	local charts_repo = self.charts_repo
	local compute_data_loader = self.compute_data_loader

	local time = os.time()

	local chart_file_data, err = compute_data_loader:requireChart(chartplay.hash)
	if not chart_file_data then
		chartplay.compute_state = "invalid"
		chartplay.computed_at = time
		charts_repo:updateChartplay(chartplay)
		return nil, "require chart: " .. err
	end

	local replay_and_data, err = compute_data_loader:requireReplay(chartplay.replay_hash)
	if not replay_and_data then
		chartplay.compute_state = "invalid"
		chartplay.computed_at = time
		charts_repo:updateChartplay(chartplay)
		return nil, "require replay: " .. err
	end

	local ctx = ComputeContext()

	local chart_chartmeta, err = ctx:fromFileData(
		chart_file_data.name,
		chart_file_data.data,
		chartplay.index
	)

	if not chart_chartmeta then
		return nil, "from file data: " .. err
	end

	local chartmeta = charts_repo:createUpdateChartmeta(chart_chartmeta.chartmeta, time)

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

	local replay = replay_and_data.replay

	ctx:applyModifierReorder(replay)

	local chartdiff = ctx:computeBase(replay)
	chartdiff = charts_repo:createUpdateChartdiff(chartdiff, time)

	local chartplay_computed, err = ctx:computeReplay(replay)
	if not chartplay_computed then
		chartplay.compute_state = "invalid"
		chartplay.computed_at = time
		charts_repo:updateChartplay(chartplay)
		return nil, "compute: " .. err
	end

	chartplay:importChartplayBase(replay)
	chartplay:importChartplayComputed(chartplay_computed)

	chartplay.compute_state = "valid"
	chartplay.computed_at = time
	charts_repo:updateChartplay(chartplay)

	return {
		chartplay_computed = chartplay_computed,
		chartdiff = chartdiff,
		chartmeta = chartmeta,
	}
end

return ChartsComputer
