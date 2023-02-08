local Class = require("Class")
local GraphicalNoteFactory = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNoteFactory")

local GraphicEngine = Class:new()

GraphicEngine.construct = function(self)
	self.notes = {}
end

GraphicEngine.longNoteShortening = 0

GraphicEngine.getCurrentTime = function(self)
	return self.editorModel.timePoint.absoluteTime
end

GraphicEngine.getInputOffset = function(self)
	return 0
end

GraphicEngine.getVisualOffset = function(self)
	return 0
end

GraphicEngine.getVisualTimeRate = function(self)
	return self.editorModel.speed
end

GraphicEngine.update = function(self)
	local editorModel = self.editorModel
	local layerData = editorModel.layerData

	local notesMap = {}
	for _, note in ipairs(self.notes) do
		notesMap[note.startNoteData] = note
	end

	local newNotes = {}
	for inputType, r in pairs(layerData.ranges.note) do
		for inputIndex, range in pairs(r) do
			local noteData = range.head
			while noteData and noteData <= range.tail do
				local note = notesMap[noteData]
				local isNew = false
				if not note then
					note = GraphicalNoteFactory:getNote(noteData)
					isNew = true
				end
				if note and isNew then
					note.currentTimePoint = editorModel.timePoint
					note.graphicEngine = self
					note.layerData = layerData
					note.input = inputType .. inputIndex
					note.inputType = inputType
					note.inputIndex = inputIndex
				end
				table.insert(newNotes, note)
				noteData = noteData.next
			end
		end
	end

	table.insert(newNotes, editorModel.grabbedNote)
	for _, note in ipairs(newNotes) do
		note:update()
	end

	self.notes = newNotes
end

return GraphicEngine
