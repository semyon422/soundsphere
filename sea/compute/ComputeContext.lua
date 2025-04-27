local class = require("class")
local valid = require("valid")
local table_util = require("table_util")
local ChartFactory = require("notechart.ChartFactory")
local DifficultyModel = require("sphere.models.DifficultyModel")
local ModifierModel = require("sphere.models.ModifierModel")
local Chartdiff = require("sea.chart.Chartdiff")
local ColumnsOrder = require("sea.chart.ColumnsOrder")
local InputMode = require("ncdk.InputMode")
local TempoRange = require("notechart.TempoRange")
local Note = require("ncdk2.notes.Note")
local Notes = require("ncdk2.notes.Notes")

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
---@return sea.Chartdiff
---@return table
function ComputeContext:computeChartdiff(replayBase)
	local chart = assert(self.chart)
	local chartmeta = assert(self.chartmeta)

	local state = {}
	state.inputMode = InputMode(chart.inputMode)

	ModifierModel:applyMeta(replayBase.modifiers, state)
	ModifierModel:apply(replayBase.modifiers, chart)

	local chartdiff = {
		mode = "mania",
		rate = replayBase.rate,
		inputmode = tostring(chart.inputMode),
		-- notes_preview = "",  -- do not generate preview
	}
	setmetatable(chartdiff, Chartdiff)
	---@cast chartdiff sea.Chartdiff
	self.difficultyModel:compute(chartdiff, chart, replayBase.rate)

	chartdiff.modifiers = replayBase.modifiers
	chartdiff.hash = chartmeta.hash
	chartdiff.index = chartmeta.index

	assert(valid.format(chartdiff:validate()))

	self.chartdiff = chartdiff

	return chartdiff, state
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

	if tempoFactor == "primary" then
		applyTempo(chart, primaryTempo)
		return
	end

	if tempoFactor == "average" and chartmeta.tempo_avg then
		applyTempo(chart, chartmeta.tempo_avg)
		return
	end

	local minTime = chartmeta.start_time
	local maxTime = minTime + chartmeta.duration

	local t = {}
	t.average, t.minimum, t.maximum = TempoRange:find(chart, minTime, maxTime)

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
