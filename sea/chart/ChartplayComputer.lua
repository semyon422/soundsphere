local IChartplayComputer = require("sea.chart.IChartplayComputer")
local Chartdiff = require("sea.chart.Chartdiff")
local ChartplayComputed = require("sea.chart.ChartplayComputed")
local DifficultyModel = require("sphere.models.DifficultyModel")
local ChartFactory = require("notechart.ChartFactory")

local FastplayController = require("sphere.controllers.FastplayController")

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
	local chart_chartmetas, err = ChartFactory:getCharts(chartfile_name, chartfile_data)
	if not chart_chartmetas then
		return nil, err
	end

	local t = chart_chartmetas[index]
	if not t then
		return nil, "chart not found"
	end

	local chart, chartmeta = t.chart, t.chartmeta

	local rhythmModel = RhythmModel()
	local replayModel = ReplayModel(rhythmModel)

	local fastplayController = FastplayController(
		rhythmModel,
		replayModel,
		self.difficultyModel
	)
	fastplayController.need_preview = true

	rhythmModel.judgements = {}
	rhythmModel.settings = require("sphere.persistence.ConfigModel.settings")
	rhythmModel.hp = rhythmModel.settings.gameplay.hp

	rhythmModel:setTimings(replay.timing_values)
	replayModel:decodeEvents(replay.events)

	fastplayController:play(chart, chartmeta, replay)

	local scoreSystem = rhythmModel.scoreEngine.scoreSystem
	local score = scoreSystem:getSlice()
	local judge = scoreSystem.soundsphere.judges["soundsphere"]

	local c = ChartplayComputed()
	c.result = "pass" -- TODO: use hp
	c.judges = {judge.counters.perfect, judge.counters["not perfect"]}
	c.accuracy = scoreSystem.normalscore.accuracyAdjusted
	c.max_combo = scoreSystem.base.maxCombo
	c.perfect_count = judge.counters.perfect
	c.miss_count = scoreSystem.base.missCount
	c.rating = 0
	c.accuracy_osu = 0
	c.accuracy_etterna = 0
	c.rating_pp = 0
	c.rating_msd = 0

	local chartdiff = rhythmModel.chartdiff
	chartdiff.hash = replay.hash
	chartdiff.index = replay.index
	chartdiff.modifiers = replay.modifiers
	chartdiff.rate = replay.rate
	chartdiff.mode = replay.mode

	return {
		chartplay_computed = c,
		chartdiff = rhythmModel.chartdiff,
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
