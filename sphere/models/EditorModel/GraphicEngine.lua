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
	local editor = self.editorModel.game.configModel.configs.settings.editor
	return editor.speed
end

GraphicEngine.selectStart = function(self)
	for _, note in ipairs(self.notes) do
		note.selected = false
	end
	self.selectedNotes = {}
	self.selecting = true
end

GraphicEngine.selectEnd = function(self)
	self.selecting = false
end

GraphicEngine.selectNote = function(self, note, keepOthers)
	if not note then
		for _, _note in ipairs(self.notes) do
			_note.selected = false
		end
		self.selectedNotes = {}
		return
	end
	if not note.selected then
		if not keepOthers then
			for _, _note in ipairs(self.notes) do
				_note.selected = false
			end
			self.selectedNotes = {}
		end
		note.selected = true
		table.insert(self.selectedNotes, note)
		return
	end
	if not keepOthers then
		return
	end
	note.selected = false
	for i, _note in ipairs(self.selectedNotes) do
		if note == _note then
			table.remove(self.selectedNotes, i)
			break
		end
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
		elseif self.selecting then
			note.selected = false
			selectedNotesMap[note.startNoteData] = nil
		end
	end

	if self.selecting then
		for _, note in ipairs(self.notes) do
			note.selected = note.selecting
			if not note.selected then
				selectedNotesMap[note.startNoteData] = nil
			end
		end
	end

	local newSelectedNotes = {}
	self.selectedNotes = newSelectedNotes
	for _, note in pairs(selectedNotesMap) do
		table.insert(newSelectedNotes, note)
	end

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

	for _, note in ipairs(editorModel.grabbedNotes) do
		table.insert(newNotes, note)
	end
	for _, note in ipairs(newNotes) do
		note:update()
	end
end

return GraphicEngine
