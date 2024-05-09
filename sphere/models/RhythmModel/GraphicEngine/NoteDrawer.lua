local class = require("class")
local GraphicalNoteFactory = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNoteFactory")
local Point = require("ncdk2.tp.Point")
local VisualPoint = require("ncdk2.visual.VisualPoint")
local table_util = require("table_util")

---@class sphere.NoteDrawer
---@operator call: sphere.NoteDrawer
local NoteDrawer = class()

---@param layer ncdk2.Layer
---@param notes notechart.Note[]
---@param column number
---@param graphicEngine sphere.GraphicEngine
function NoteDrawer:new(layer, notes, column, graphicEngine)
	self.layer = layer
	self._notes = notes
	self.column = column
	self.graphicEngine = graphicEngine
end

local function sort_const(a, b)
	return a.startNote.visualPoint.point:compare(b.startNote.visualPoint.point)
end

local function sort_visual(a, b)
	return a.startNote.visualPoint:compare(b.startNote.visualPoint)
end

function NoteDrawer:load()
	local graphicEngine = self.graphicEngine
	local layer = self.layer

	local inputMap = graphicEngine.chart.inputMode:getInputMap()

	self.eventOffset = 0

	self.currentVisualPointIndex = 1
	self.currentVisualPoint = VisualPoint(Point())

	self.notes = {}
	local notes = self.notes

	self.noteByTimePoint = {}

	for _, _note in ipairs(self._notes) do
		local note = GraphicalNoteFactory:getNote(_note)
		if note then
			local iti = inputMap[self.column]
			note.currentVisualPoint = self.currentVisualPoint
			note.graphicEngine = graphicEngine
			note.layer = layer
			note.column = self.column
			note.inputType = iti[1]
			note.inputIndex = iti[2]
			table.insert(notes, note)

			if self.graphicEngine.eventBasedRender then
				local endNoteData = note.startNote.endNoteData
				if not endNoteData then
					self.noteByTimePoint[note.startNote.timePoint] = {
						note = note,
						show = true,
						hide = true,
					}
				else
					self.noteByTimePoint[note.startNote.timePoint] = {
						note = note,
						show = true,
					}
					self.noteByTimePoint[endNoteData.timePoint] = {
						note = note,
						hide = true,
					}
				end
			end
		end
	end

	if graphicEngine.constant then
		table.sort(notes, sort_const)
	else
		table.sort(notes, sort_visual)
	end

	for i, note in ipairs(notes) do
		note.nextNote = notes[i + 1]
	end

	self.startNoteIndex = 1
	self.endNoteIndex = 0

	self.visibleNotes = {}
	self.visibleNotesList = {}
end

function NoteDrawer:updateCurrentTime()
	local graphicEngine = self.graphicEngine
	local vp = self.currentVisualPoint
	vp.point.absoluteTime = graphicEngine:getCurrentTime() - graphicEngine:getInputOffset()

	local interpolator = self.layer.visual.interpolator
	local visualPoints = self.layer.visualPoints

	self.currentVisualPointIndex = interpolator:interpolate(
		visualPoints, self.currentVisualPointIndex, vp, "absolute"
	)
end

function NoteDrawer:update()
	if self.graphicEngine.eventBasedRender then
		return self:updateEventBased()
	end
	return self:updateSorted()
end

function NoteDrawer:updateEventBased()
	self:updateCurrentTime()

	local currentTime = self.currentVisualPoint.point.absoluteTime
	while self.eventOffset < #self.events do
		local event = self.events[self.eventOffset + 1]
		if event.time > currentTime then
			break
		end
		self.eventOffset = self.eventOffset + 1
		if event.action == "show" then
			local noteInfo = self.noteByTimePoint[event.timePoint]
			if noteInfo and noteInfo.show then
				self.visibleNotes[noteInfo.note] = true
			end
		elseif event.action == "hide" then
			local noteInfo = self.noteByTimePoint[event.timePoint]
			if noteInfo and noteInfo.hide then
				self.visibleNotes[noteInfo.note] = nil
			end
		end
	end

	local visibleNotesList = self.visibleNotesList
	table_util.clear(visibleNotesList)

	for note in pairs(self.visibleNotes) do
		note:update()
		table.insert(visibleNotesList, note)
	end

	table.sort(visibleNotesList, sort_const)
end

function NoteDrawer:updateSorted()
	self:updateCurrentTime()

	local notes = self.notes
	local note

	for i = self.startNoteIndex, self.endNoteIndex do
		notes[i]:update()
	end

	for i = self.startNoteIndex, 2, -1 do
		note = notes[i - 1]
		note:update()
		if note:willDrawBeforeStart() or i ~= self.startNoteIndex then
			break
		end
		self.startNoteIndex = self.startNoteIndex - 1
	end

	for i = self.endNoteIndex, #notes - 1, 1 do
		note = notes[i + 1]
		note:update()
		if note:willDrawAfterEnd() or i ~= self.endNoteIndex then
			break
		end
		self.endNoteIndex = self.endNoteIndex + 1
	end

	for i = self.startNoteIndex, self.endNoteIndex do
		note = notes[i]
		if not note:willDrawBeforeStart() then
			break
		end
		self.startNoteIndex = self.startNoteIndex + 1
	end

	for i = self.endNoteIndex, self.startNoteIndex, -1 do
		note = notes[i]
		if not note:willDrawAfterEnd() then
			break
		end
		self.endNoteIndex = self.endNoteIndex - 1
	end
end

return NoteDrawer
