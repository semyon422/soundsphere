local IChartplayComputer = require("sea.chart.IChartplayComputer")
local Chartdiff = require("sea.chart.Chartdiff")
local DifficultyModel = require("sphere.models.DifficultyModel")
local ChartFactory = require("notechart.ChartFactory")

local FastplayController = require("sphere.controllers.FastplayController")

local ReplayModel = require("sphere.models.ReplayModel")

local ModifierModel = require("sphere.models.ModifierModel")
local RhythmModel = require("sphere.models.RhythmModel")
local PlayContext = require("sphere.models.PlayContext")

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
	local chart_chartmetas, err = self:getCharts(chartfile_name, chartfile_data)
	if not chart_chartmetas then
		return nil, err
	end

	local t = chart_chartmetas[index]
	if not t then
		return nil, "chart not found"
	end

	local chart, chartmeta, chartdiff = t.chart, t.chartmeta, t.chartdiff

	local fastplayController = FastplayController()

	local playContext = PlayContext()
	local rhythmModel = RhythmModel()
	local replayModel = ReplayModel(rhythmModel)
	fastplayController.rhythmModel = rhythmModel
	fastplayController.replayModel = replayModel
	fastplayController.difficultyModel = self.difficultyModel
	fastplayController.playContext = playContext

	rhythmModel.judgements = {}
	rhythmModel.settings = require("sphere.persistence.ConfigModel.settings")
	rhythmModel.hp = rhythmModel.settings.gameplay.hp

	playContext:load(replay)
	ModifierModel:fixOldFormat(replay.modifiers)

	rhythmModel:setTimings(replay.timings)
	replayModel:decodeEvents(replay.events)

	fastplayController:play(chart, chartmeta, replay)

	local score = rhythmModel.scoreEngine.scoreSystem:getSlice()

	return {
		chartplay_computed = score,
		chartdiff = chartdiff,
		chartmeta = chartmeta,
	}
end

---@param name string
---@param data string
---@param index integer
---@return sea.Chartmeta?
---@return string?
function ChartplayComputer:computeChartmeta(name, data, index)
	local charts, err = self:getCharts(name, data)
	if not charts then
		return nil, err
	end

	local chart = charts[index]
	if not chart then
		return nil, "not found"
	end

	return chart.chartmeta
end

--------------------------------------------------------------------------------

---@param name string
---@param data string
---@return {chart: ncdk2.Chart, chartmeta: sea.Chartmeta, chartdiff: sea.Chartdiff}[]?
---@return string?
function ChartplayComputer:getCharts(name, data)
	local chart_chartmetas, err = ChartFactory:getCharts(name, data)
	if not chart_chartmetas then
		return nil, err
	end

	---@cast chart_chartmetas {chart: ncdk2.Chart, chartmeta: sea.Chartmeta, chartdiff: sea.Chartdiff}[]

	for _, t in ipairs(chart_chartmetas) do
		t.chartdiff = Chartdiff()
		self.difficultyModel:compute(t.chartdiff, t.chart, 1)
	end

	return chart_chartmetas
end

return ChartplayComputer
