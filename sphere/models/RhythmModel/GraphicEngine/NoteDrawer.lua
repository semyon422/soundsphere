local class = require("class")
local GraphicalNoteFactory = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNoteFactory")

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

	self.currentTimePointIndex = 1
	self.currentTimePoint = layerData:newTimePoint()

	self.notes = {}
	local notes = self.notes

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
end

function NoteDrawer:updateCurrentTime()
	local graphicEngine = self.graphicEngine
	local timePoint = self.currentTimePoint
	timePoint.absoluteTime = graphicEngine:getCurrentTime() - graphicEngine:getInputOffset()
	self.currentTimePointIndex = self.layerData:interpolateTimePointAbsolute(self.currentTimePointIndex, timePoint)
end

function NoteDrawer:update()
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
