local Class = require("Class")
local GraphicalNoteFactory = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNoteFactory")

local GraphicEngine = Class:new()

GraphicEngine.construct = function(self)
	self.notes = {}
	self.selectedNotes = {}
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

GraphicEngine.unselectNotes = function(self)
	for _, note in ipairs(self.notes) do
		note.selected = false
	end
	self.selectedNotes = {}
end

GraphicEngine.updateSelectedNotes = function(self)
	for _, note in ipairs(self.notes) do
		note.selected = note.selecting
	end
end

GraphicEngine.update = function(self)
	local editorModel = self.editorModel
	local layerData = editorModel.layerData

	local selectedNotesMap = {}
	for _, note in ipairs(self.selectedNotes) do
		selectedNotesMap[note.startNoteData] = note
		note.selected = true
	end

	local notesMap = {}
	for _, note in ipairs(self.notes) do
		notesMap[note.startNoteData] = note
		if note.selecting then
			selectedNotesMap[note.startNoteData] = note
		end
	end

	local newSelectedNotes = {}
	for _, note in pairs(selectedNotesMap) do
		table.insert(newSelectedNotes, note)
	end
	self.selectedNotes = newSelectedNotes

	local newNotes = {}
	self.notes = newNotes

	for inputType, r in pairs(layerData.ranges.note) do
		for inputIndex, range in pairs(r) do
			local noteData = range.head
			while noteData and noteData <= range.tail do
				local note = notesMap[noteData] or selectedNotesMap[noteData]
				local isNew = false
				if not note then
					note = GraphicalNoteFactory:getNote(noteData)
					isNew = true
				end
				if note and isNew then
					note.currentTimePoint = editorModel.timePoint
					note.graphicEngine = self
					note.layerData = layerData
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
end

return GraphicEngine
