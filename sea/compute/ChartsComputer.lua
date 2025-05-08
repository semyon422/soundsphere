local class = require("class")

---@class sea.ChartsComputer
---@operator call: sea.ChartsComputer
local ChartsComputer = class()

---@param compute_data_loader sea.ComputeDataLoader
---@param chartplay_computer sea.IChartplayComputer
---@param charts_repo sea.IChartsRepo
function ChartsComputer:new(compute_data_loader, chartplay_computer, charts_repo)
	self.compute_data_loader = compute_data_loader
	self.chartplay_computer = chartplay_computer
	self.charts_repo = charts_repo
end

---@param chartplay sea.Chartplay
---@return {chartplay_computed: sea.ChartplayComputed, chartdiff: sea.Chartdiff, chartmeta: sea.Chartmeta}?
---@return string?
function ChartsComputer:computeChartplay(chartplay)
	local charts_repo = self.charts_repo
	local compute_data_loader = self.compute_data_loader
	local chartplay_computer = self.chartplay_computer

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

	local replay = replay_and_data.replay

	local ret, err = chartplay_computer:compute(
		chart_file_data.name,
		chart_file_data.data,
		chartplay.index,
		replay
	)
	if not ret then
		chartplay.compute_state = "invalid"
		chartplay.computed_at = time
		charts_repo:updateChartplay(chartplay)
		return nil, "compute: " .. err
	end

	local computed_chartdiff = ret.chartdiff
	local computed_chartmeta = ret.chartmeta
	local chartplay_computed = ret.chartplay_computed

	chartplay:importChartplayBase(replay)
	chartplay:importChartplayComputed(chartplay_computed)

	chartplay.compute_state = "valid"
	chartplay.computed_at = time
	charts_repo:updateChartplay(chartplay)

	computed_chartdiff.computed_at = time
	computed_chartmeta.computed_at = time

	local chartdiff = charts_repo:getChartdiffByChartkey(computed_chartdiff)
	if not chartdiff then
		computed_chartdiff.created_at = time
		computed_chartdiff.computed_at = time
		chartdiff = charts_repo:createChartdiff(computed_chartdiff)
	elseif not chartdiff:equalsComputed(computed_chartdiff) then
		computed_chartdiff.id = chartdiff.id
		computed_chartdiff.computed_at = time
		chartdiff = charts_repo:updateChartdiff(computed_chartdiff)
		-- add a note on chartdiff page about this change
	end

	local chartmeta = charts_repo:getChartmetaByHashIndex(computed_chartmeta.hash, computed_chartmeta.index)
	if not chartmeta then
		computed_chartmeta.created_at = time
		computed_chartmeta.computed_at = time
		chartmeta = charts_repo:createChartmeta(computed_chartmeta)
	elseif not chartmeta:equalsComputed(computed_chartmeta) then
		computed_chartmeta.id = chartmeta.id
		computed_chartmeta.computed_at = time
		chartmeta = charts_repo:updateChartmeta(computed_chartmeta)
		-- add a note on chartmeta page about this change
	end

	if #chartdiff.modifiers > 0 or chartdiff.rate ~= 1 then
		-- create default chartdiff if missing
	end

	return ret
end

return ChartsComputer
