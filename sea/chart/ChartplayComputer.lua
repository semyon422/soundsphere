local IChartplayComputer = require("sea.chart.IChartplayComputer")
local Chartdiff = require("sea.chart.Chartdiff")
local DifficultyModel = require("sphere.models.DifficultyModel")
local ChartFactory = require("notechart.ChartFactory")

local FastplayController = require("sphere.controllers.FastplayController")

local Replay = require("sphere.models.ReplayModel.Replay")
local ReplayModel = require("sphere.models.ReplayModel")

local ModifierModel = require("sphere.models.ModifierModel")
local RhythmModel = require("sphere.models.RhythmModel")
local PlayContext = require("sphere.models.PlayContext")
local ModifierEncoder = require("sphere.models.ModifierEncoder")

---@class sea.ChartplayComputer: sea.IChartplayComputer
---@operator call: sea.ChartplayComputer
local ChartplayComputer = IChartplayComputer + {}

---@param charts_storage sea.IKeyValueStorage
---@param replays_storage sea.IKeyValueStorage
function ChartplayComputer:new(charts_storage, replays_storage)
	self.charts_storage = charts_storage
	self.replays_storage = replays_storage
	self.difficultyModel = DifficultyModel()
end

---@param chartplay sea.Chartplay
---@param chartfile sea.Chartfile
---@return {chartplay: sea.Chartplay, chartdiff: sea.Chartdiff, chartmeta: sea.Chartmeta}?
---@return string?
function ChartplayComputer:compute(chartplay, chartfile)
	local chart_chartmetas, err = self:getCharts(chartfile)
	if not chart_chartmetas then
		return nil, err
	end

	local t = chart_chartmetas[chartplay.index]
	if not t then
		return nil, "not found"
	end

	local replay, err = self:getReplay(chartplay)
	if not replay then
		return nil, err
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
	replayModel.replay = replay

	fastplayController:play(chart, chartmeta, replay)

	local score = rhythmModel.scoreEngine.scoreSystem:getSlice()

	-- return 200, {
	-- 	score = score,
	-- 	inputMode = tostring(chart.inputMode),
	-- 	playContext = playContext,
	-- 	modifiers = replay.modifiers,
	-- 	modifiersEncoded = ModifierEncoder:encode(replay.modifiers),
	-- 	modifiersHash = ModifierEncoder:hash(replay.modifiers),
	-- 	modifiersString = ModifierModel:getString(replay.modifiers),
	-- }

	return {
		chartplay = score,
		chartdiff = chartdiff,
		chartmeta = chartmeta,
	}
end

---@param chartfile sea.Chartfile
---@param index integer
---@return sea.Chartmeta?
---@return string?
function ChartplayComputer:computeChartmeta(chartfile, index)
	local charts, err = self:getCharts(chartfile)
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

---@param chartfile sea.Chartfile
---@return {chart: ncdk2.Chart, chartmeta: sea.Chartmeta, chartdiff: sea.Chartdiff}[]?
---@return string?
function ChartplayComputer:getCharts(chartfile)
	local data, err = self.charts_storage:get(chartfile.hash)
	if not data then
		return nil, err
	end

	local chart_chartmetas, err = ChartFactory:getCharts(chartfile.name, data)
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

---@param chartplay sea.Chartplay
---@return sphere.Replay?
---@return string?
function ChartplayComputer:getReplay(chartplay)
	local data, err = self.charts_storage:get(chartplay.events_hash)
	if not data then
		return nil, err
	end

	return Replay():fromString(data)
end

return ChartplayComputer
