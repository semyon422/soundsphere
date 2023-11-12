local class = require("class")
local GraphicalNoteFactory = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNoteFactory")
local table_util = require("table_util")

---@class sphere.NoteDrawer
---@operator call: sphere.NoteDrawer
local NoteDrawer = class()

local function sort_const(a, b)
	return a.startNoteData.timePoint:compare(b.startNoteData.timePoint, "absolute")
end

local function sort_visual(a, b)
	return a.startNoteData.timePoint:compare(b.startNoteData.timePoint, "visual")
end

function NoteDrawer:load()
	local graphicEngine = self.graphicEngine
	local logicEngine = graphicEngine.logicEngine

	local layerData = self.layerData
	self.eventOffset = 0

	self.currentTimePointIndex = 1
	self.currentTimePoint = layerData:newTimePoint()

	self.notes = {}
	local notes = self.notes

	self.noteByTimePoint = {}

	for _, noteData in ipairs(self.noteDatas) do
		local note = GraphicalNoteFactory:getNote(noteData)
		if note then
			note.currentTimePoint = self.currentTimePoint
			note.graphicEngine = graphicEngine
			note.layerData = layerData
			note.logicalNote = logicEngine:getLogicalNote(noteData)
			note.inputType = self.inputType
			note.inputIndex = self.inputIndex
			table.insert(notes, note)
			self.noteByTimePoint[noteData.timePoint] = note
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
	local timePoint = self.currentTimePoint
	timePoint.absoluteTime = graphicEngine:getCurrentTime() - graphicEngine:getInputOffset()
	self.currentTimePointIndex = self.layerData:interpolateTimePointAbsolute(self.currentTimePointIndex, timePoint)
end

function NoteDrawer:update()
	if self.graphicEngine.eventBasedRender then
		return self:updateEventBased()
	end
	return self:updateSorted()
end

function NoteDrawer:updateEventBased()
	self:updateCurrentTime()

	local currentTime = self.currentTimePoint.absoluteTime
	while self.eventOffset < #self.events do
		local event = self.events[self.eventOffset + 1]
		if event.time > currentTime then
			break
		end
		self.eventOffset = self.eventOffset + 1
		if event.action == "show" then
			local note = self.noteByTimePoint[event.timePoint]
			if note then
				self.visibleNotes[note] = true
			end
		elseif event.action == "hide" then
			local note = self.noteByTimePoint[event.timePoint]
			if note then
				self.visibleNotes[note] = nil
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
