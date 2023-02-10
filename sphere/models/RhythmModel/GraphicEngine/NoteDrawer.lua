local Class = require("Class")
local GraphicalNoteFactory	= require("sphere.models.RhythmModel.GraphicEngine.GraphicalNoteFactory")

local NoteDrawer = Class:new()

NoteDrawer.load = function(self)
	local graphicEngine = self.graphicEngine
	local logicEngine = graphicEngine.rhythmModel.logicEngine

	local layerData = self.layerData

	self.currentTimePointIndex = 1
	self.currentTimePoint = layerData:newTimePoint()

	local sharedLogicalNotes = logicEngine.sharedLogicalNotes or {}

	self.notes = {}
	local notes = self.notes

	for _, noteData in ipairs(self.noteDatas) do
		local graphicalNote = GraphicalNoteFactory:getNote(noteData)
		if graphicalNote then
			graphicalNote.currentTimePoint = self.currentTimePoint
			graphicalNote.graphicEngine = graphicEngine
			graphicalNote.layerData = layerData
			graphicalNote.logicalNote = sharedLogicalNotes[noteData]
			graphicalNote.inputType = self.inputType
			graphicalNote.inputIndex = self.inputIndex
			table.insert(notes, graphicalNote)
		end
	end

	if notes[1] then
		table.sort(notes, function(a, b)
			return a.startNoteData.timePoint:compare(b.startNoteData.timePoint, "visual")
		end)
		for index, graphicalNote in ipairs(notes) do
			graphicalNote.nextNote = notes[index + 1]
		end
	end

	self.startNoteIndex = 1
	self.endNoteIndex = 0
end

NoteDrawer.updateCurrentTime = function(self)
	local graphicEngine = self.graphicEngine
	local timePoint = self.currentTimePoint
	timePoint.absoluteTime = graphicEngine:getCurrentTime() - graphicEngine:getInputOffset()
	self.currentTimePointIndex = self.layerData:interpolateTimePointAbsolute(self.currentTimePointIndex, timePoint)
end

NoteDrawer.update = function(self)
	self:updateCurrentTime()

	local notes = self.notes
	local note

	for i = self.startNoteIndex, self.endNoteIndex do
		notes[i]:update()
	end

	for i = self.startNoteIndex, 2, -1 do
		note = notes[i - 1]
		note:update()
		if not note:willDrawBeforeStart() and i == self.startNoteIndex then
			self.startNoteIndex = self.startNoteIndex - 1
		else
			break
		end
	end

	for i = self.endNoteIndex, #notes - 1, 1 do
		note = notes[i + 1]
		note:update()
		if not note:willDrawAfterEnd() and i == self.endNoteIndex then
			self.endNoteIndex = self.endNoteIndex + 1
		else
			break
		end
	end

	for i = self.startNoteIndex, self.endNoteIndex do
		note = notes[i]
		if note:willDrawBeforeStart() then
			self.startNoteIndex = self.startNoteIndex + 1
		else
			break
		end
	end

	for i = self.endNoteIndex, self.startNoteIndex, -1 do
		note = notes[i]
		if note:willDrawAfterEnd() then
			self.endNoteIndex = self.endNoteIndex - 1
		else
			break
		end
	end
end

return NoteDrawer
