local IChartplayComputer = require("sea.compute.IChartplayComputer")
local DifficultyModel = require("sphere.models.DifficultyModel")
local ChartFactory = require("notechart.ChartFactory")
local ComputeContext = require("sea.compute.ComputeContext")

local ReplayModel = require("sphere.models.ReplayModel")
local RhythmModel = require("sphere.models.RhythmModel")

---@class sea.ChartplayComputer: sea.IChartplayComputer
---@operator call: sea.ChartplayComputer
local ChartplayComputer = IChartplayComputer + {}

function ChartplayComputer:new()
	self.difficultyModel = DifficultyModel()
end

---@param chartfile_name string
---@param chartfile_data string
---@param index integer
---@param replay sea.Replay
---@return {chartplay_computed: sea.ChartplayComputed, chartdiff: sea.Chartdiff, chartmeta: sea.Chartmeta}?
---@return string?
function ChartplayComputer:compute(chartfile_name, chartfile_data, index, replay)
	local computeContext = ComputeContext()

	local chart_chartmeta, err = computeContext:fromFileData(chartfile_name, chartfile_data, index)
	if not chart_chartmeta then
		return nil, "from file data: " .. err
	end

	computeContext:applyModifierReorder(replay)
	computeContext:computeBase(replay)

	return self:computeFromContext(computeContext, replay)
end

---@param computeContext sea.ComputeContext
---@param replay sea.Replay
---@return {chartplay_computed: sea.ChartplayComputed, chartdiff: sea.Chartdiff, chartmeta: sea.Chartmeta}?
---@return string?
function ChartplayComputer:computeFromContext(computeContext, replay)
	local chartmeta = assert(computeContext.chartmeta)
	assert(computeContext.chartdiff)

	local rhythmModel = RhythmModel()
	local replayModel = ReplayModel(rhythmModel)

	rhythmModel:setReplayBase(replay)
	replayModel:decodeEvents(replay.events)

	computeContext:computePlay(rhythmModel, replayModel)

	local timings = assert(replay.timings or chartmeta.timings)
	rhythmModel.scoreEngine:createAndSelectByTimings(timings, replay.subtimings)

	local c = rhythmModel:getChartplayComputed()

	return {
		chartplay_computed = c,
		chartdiff = computeContext.chartdiff,
		chartmeta = chartmeta,
	}
end

---@param name string
---@param data string
---@param index integer
---@return sea.Chartmeta?
---@return string?
function ChartplayComputer:computeChartmeta(name, data, index)
	local chart_chartmetas, err = ChartFactory:getCharts(name, data)
	if not chart_chartmetas then
		return nil, err
	end

	local chart_chartmeta = chart_chartmetas[index]
	if not chart_chartmeta then
		return nil, "not found"
	end

	return chart_chartmeta.chartmeta
end

return ChartplayComputer
