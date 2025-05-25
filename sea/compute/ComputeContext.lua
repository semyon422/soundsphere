local class = require("class")
local valid = require("valid")
local table_util = require("table_util")
local ChartFactory = require("notechart.ChartFactory")
local DifficultyModel = require("sphere.models.DifficultyModel")
local ModifierModel = require("sphere.models.ModifierModel")
local Chartdiff = require("sea.chart.Chartdiff")
local ColumnsOrder = require("sea.chart.ColumnsOrder")
local ModifiersMetaState = require("sea.compute.ModifiersMetaState")
local InputMode = require("ncdk.InputMode")
local TempoRange = require("notechart.TempoRange")
local Note = require("ncdk2.notes.Note")
local Notes = require("ncdk2.notes.Notes")
local ReplayModel = require("sphere.models.ReplayModel")
local RhythmModel = require("sphere.models.RhythmModel")

---@class sea.ComputeContext
---@operator call: sea.ComputeContext
---@field chart_chartmetas {chart: ncdk2.Chart, chartmeta: sea.Chartmeta}[]?
---@field chart ncdk2.Chart?
---@field chartmeta sea.Chartmeta?
---@field chartdiff sea.Chartdiff?
---@field chartplay sea.Chartplay?
local ComputeContext = class()

function ComputeContext:new()
	self.difficultyModel = DifficultyModel()
end

---@param name string
---@param data string
---@param index integer
---@return {chart: ncdk2.Chart, chartmeta: sea.Chartmeta}?
---@return string?
function ComputeContext:fromFileData(name, data, index)
	local ccm, err = ChartFactory:getCharts(name, data)
	if not ccm then
		return nil, "get charts: " .. err
	end
	self.chart_chartmetas = ccm
	self.chart = ccm[index].chart
	self.chartmeta = ccm[index].chartmeta
	self:toAbsolute()
	return {
		chart = self.chart,
		chartmeta = self.chartmeta,
	}
end

---@return ncdk2.Chart?
---@return sea.Chartmeta?
function ComputeContext:toAbsolute()
	self.chart.layers.main:toAbsolute()
end

---@param replayBase sea.ReplayBase
---@param inputMode ncdk.InputMode?
---@return ncdk2.Chart?
---@return sea.Chartmeta?
function ComputeContext:applyModifierReorder(replayBase, inputMode)
	if not inputMode then
		local chart = assert(self.chart)
		inputMode = chart.inputMode
	end

	local state = ModifiersMetaState(inputMode)
	ModifierModel:applyMeta(replayBase.modifiers, state)

	local modifiers = table_util.copy(replayBase.modifiers)
	for i = #modifiers, #modifiers - state.reorders + 1, -1 do
		table.remove(modifiers, i)
	end
	replayBase.modifiers = modifiers

	local co = ColumnsOrder(state.inputMode)
	co:apply(state.columns_order.map)
	co:apply(ColumnsOrder(state.inputMode, replayBase.columns_order).map)

	replayBase.columns_order = co:export()
end

---@param chart ncdk2.Chart
---@param rate number
---@return sea.Chartdiff
function ComputeContext:computeChartdiff(chart, rate)
	local chartdiff = {
		mode = "mania",
		rate = rate,
		inputmode = tostring(chart.inputMode),
	}
	setmetatable(chartdiff, Chartdiff)
	---@cast chartdiff sea.Chartdiff
	self.difficultyModel:compute(chartdiff, chart, rate)

	return chartdiff
end

---@param replayBase sea.ReplayBase
---@return sea.Chartdiff
---@return sea.ModifiersMetaState
function ComputeContext:computeBase(replayBase)
	local chart = assert(self.chart)
	local chartmeta = assert(self.chartmeta)

	local state = ModifiersMetaState(chart.inputMode)

	ModifierModel:applyMeta(replayBase.modifiers, state)
	ModifierModel:apply(replayBase.modifiers, chart)

	assert(state.reorders == 0, "ending reorder modifiers")

	if replayBase.tap_only then
		self:applyTapOnly()
	end

	local chartdiff = self:computeChartdiff(chart, replayBase.rate)

	chartdiff.modifiers = replayBase.modifiers
	chartdiff.hash = chartmeta.hash
	chartdiff.index = chartmeta.index

	assert(valid.format(chartdiff:validate()))

	self.chartdiff = chartdiff
	self.state = state

	self:applyColumnOrder(replayBase.columns_order)

	return chartdiff, state
end

---@param replay sea.Replay
---@return sea.ChartplayComputed?
---@return string?
function ComputeContext:computeReplay(replay)
	local chartmeta = assert(self.chartmeta)
	assert(self.chartdiff)

	local rhythmModel = RhythmModel()
	local replayModel = ReplayModel(rhythmModel)

	rhythmModel:setReplayBase(replay)
	replayModel:decodeEvents(replay.events)

	self:computePlay(rhythmModel, replayModel)

	local timings = assert(replay.timings or chartmeta.timings)
	rhythmModel.scoreEngine:createAndSelectByTimings(timings, replay.subtimings)

	local chartplay_computed = rhythmModel:getChartplayComputed()

	return chartplay_computed
end

---@param rhythmModel sphere.RhythmModel
---@param replayModel sphere.ReplayModel
function ComputeContext:computePlay(rhythmModel, replayModel)
	local chart = assert(self.chart)
	local chartmeta = assert(self.chartmeta)
	local chartdiff = assert(self.chartdiff)
	local state = assert(self.state)

	rhythmModel:setWindUp(state.windUp)
	rhythmModel:setNoteChart(chart, chartmeta, chartdiff)
	rhythmModel:setPlayTime(chartdiff.start_time, chartdiff.duration)

	replayModel:setMode("replay")
	rhythmModel.inputManager:setMode("internal")

	rhythmModel:loadLogicEngines()
	replayModel:load()

	rhythmModel.timeEngine.currentTime = math.huge
	replayModel:update()
	rhythmModel.logicEngine:update()

	rhythmModel:unloadAllEngines()
end

---@see sphere.LogicalNoteFactory
function ComputeContext:applyTapOnly()
	local chart = assert(self.chart)

	local long_types = table_util.invert({
		"hold",
		"laser",
		"drumroll",
	})

	for _, note in ipairs(chart.notes:getLinkedNotes()) do
		local t = note:getType()
		if long_types[t] then
			if note.endNote then
				note.endNote.type = "ignore"
			end
			note:unlink()
			note:setType("tap")
		end
	end
end

---@param columns_order integer[]?
function ComputeContext:applyColumnOrder(columns_order)
	if not columns_order then
		return
	end

	local chart = assert(self.chart)
	local co = ColumnsOrder(chart.inputMode, columns_order)
	local map = co.map

	local new_notes = Notes()
	for _, note in chart.notes:iter() do
		note.column = map[note.column] or note.column
		new_notes:insert(note)
	end
	chart.notes = new_notes
end

---@param chart ncdk2.Chart
---@param tempo number
local function applyTempo(chart, tempo)
	for _, visual in ipairs(chart:getVisuals()) do
		visual.primaryTempo = tempo
		visual:compute()
	end
end

function ComputeContext:swapVelocityType()
	local chart = assert(self.chart)
	for _, visual in ipairs(chart:getVisuals()) do
		visual.tempoMultiplyTarget = "local"
		for _, vp in ipairs(visual.points) do
			local vel = vp._velocity
			if vel then
				vel.localSpeed, vel.currentSpeed = vel.currentSpeed, vel.localSpeed
			end
		end
		visual:compute()
	end
end

---@param tempoFactor string
---@param primaryTempo number
function ComputeContext:applyTempo(tempoFactor, primaryTempo)
	local chart = assert(self.chart)
	local chartmeta = assert(self.chartmeta)
	local chartdiff = assert(self.chartdiff)

	if tempoFactor == "primary" then
		applyTempo(chart, primaryTempo)
		return
	end

	if tempoFactor == "average" and chartmeta.tempo_avg then
		applyTempo(chart, chartmeta.tempo_avg)
		return
	end

	local start_time = chartdiff.start_time
	local end_time = start_time + chartdiff.duration

	local t = {}
	t.average, t.minimum, t.maximum = TempoRange:find(chart, start_time, end_time)

	applyTempo(chart, t[tempoFactor])
end

function ComputeContext:applyAutoKeysound()
	local chart = assert(self.chart)
	for _, note in chart.notes:iter() do
		if note.type == "tap" or note.type == "hold" then
			local soundNote = chart.notes:get(note.visualPoint, "auto")
			if not soundNote then
				soundNote = Note(note.visualPoint, "auto", "sample")
				chart.notes:insert(soundNote)
				soundNote.data.sounds = {}
			end

			if note.data.sounds then
				for _, t in ipairs(note.data.sounds) do
					table.insert(soundNote.data.sounds, t)
				end
				note.data.sounds = {}
			end
		end
	end
end

return ComputeContext
