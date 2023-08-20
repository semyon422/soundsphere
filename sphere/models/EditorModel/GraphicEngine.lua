local class = require("class")
local EditorNoteFactory = require("sphere.models.EditorModel.EditorNoteFactory")

---@class sphere.EditorGraphicEngine
---@operator call: sphere.EditorGraphicEngine
local GraphicEngine = class()

function GraphicEngine:new()
	self.notes = {}
	self.selectedNotes = {}
end

function GraphicEngine:reset()
	self:selectEnd()
	self:selectNote()
	self.notes = {}
	self.selectedNotes = {}
end

GraphicEngine.longNoteShortening = 0

---@return number
function GraphicEngine:getCurrentTime()
	return self.editorModel.timePoint.absoluteTime
end

---@return number
function GraphicEngine:getInputOffset()
	return 0
end

---@return number
function GraphicEngine:getVisualOffset()
	return 0
end

---@return number
function GraphicEngine:getVisualTimeRate()
	local editor = self.editorModel.configModel.configs.settings.editor
	return editor.speed
end

function GraphicEngine:selectStart()
	for _, note in ipairs(self.notes) do
		note.selected = false
	end
	self.selectedNotes = {}
	self.selecting = true
end

function GraphicEngine:selectEnd()
	self.selecting = false
end

---@param note sphere.GraphicalNote?
---@param keepOthers boolean?
function GraphicEngine:selectNote(note, keepOthers)
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

---@param noteData ncdk.NoteData
---@param editorModel sphere.EditorModel
---@param inputType string
---@param inputIndex number
---@return sphere.GraphicalNote?
function GraphicEngine:newNote(noteData, editorModel, inputType, inputIndex)
	local note = EditorNoteFactory:getNote(noteData)
	if not note then
		return
	end
	note.editorModel = editorModel
	note.currentTimePoint = editorModel.timePoint
	note.graphicEngine = self
	note.layerData = editorModel.layerData
	note.inputType = inputType
	note.inputIndex = inputIndex
	return note
end

function GraphicEngine:update()
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
				local note = notesMap[noteData] or
					selectedNotesMap[noteData] or
					self:newNote(noteData, editorModel, inputType, inputIndex)
				table.insert(newNotes, note)
				noteData = noteData.next
			end
		end
	end

	for _, note in ipairs(editorModel.noteManager.grabbedNotes) do
		table.insert(newNotes, note)
	end
	for _, note in ipairs(newNotes) do
		note:update()
	end
end

return GraphicEngine
