local Class = require("Class")
local GraphicalNoteFactory = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNoteFactory")

local NoteDrawer = Class:new()

NoteDrawer.load = function(self)
	local layerData = self.editorModel.layerData
	self.notes = {}

	self.currentTimePointIndex = 1
	self.currentTimePoint = layerData:newTimePoint()

	self.notes = {}
	local notes = self.notes

	for _, noteData in ipairs(self.noteDatas) do
		local graphicalNote = GraphicalNoteFactory:getNote(noteData)
		if graphicalNote then
			graphicalNote.currentTimePoint = self.currentTimePoint
			graphicalNote.graphicEngine = self
			-- graphicalNote.timeEngine = timeEngine
			graphicalNote.layerData = layerData
			graphicalNote.input = self.inputType .. self.inputIndex
			table.insert(notes, graphicalNote)
		end
	end
end

NoteDrawer.updateNotes = function(self)
	local ld = self.editorModel.layerData
	local currentTime = self.editorModel.timePoint.absoluteTime

	for inputType, r in pairs(ld.ranges.note) do
		for inputIndex, range in pairs(r) do
			local noteData = range.head
			while noteData and noteData <= range.tail do


				noteData = noteData.next
			end
		end
	end
end

return NoteDrawer
