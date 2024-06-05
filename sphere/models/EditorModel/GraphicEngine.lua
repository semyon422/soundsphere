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

---@param noteData ncdk.NoteData
---@return sphere.LogicalNote?
function GraphicEngine:getLogicalNote(noteData)
	return
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

---@param note sphere.EditorNote?
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
---@param column ncdk2.Column
---@return sphere.EditorNote?
function GraphicEngine:newNote(noteData, editorModel, column)
	local note = EditorNoteFactory:getNote(noteData)
	if not note then
		return
	end
	note.editorModel = editorModel
	note.currentTimePoint = editorModel.timePoint
	note.graphicEngine = self
	note.layerData = editorModel.layerData
	note.column = column
	return note
end

function GraphicEngine:update()
	local editorModel = self.editorModel
	local layerData = editorModel.layerData

	local selectedNotesMap = {}
	for _, note in ipairs(self.selectedNotes) do
		selectedNotesMap[note.startNote] = note
		note.selected = true
	end

	local notesMap = {}
	for _, note in ipairs(self.notes) do
		notesMap[note.startNote] = note
		if note.selecting then
			selectedNotesMap[note.startNote] = note
		elseif self.selecting then
			note.selected = false
			selectedNotesMap[note.startNote] = nil
		end
	end

	if self.selecting then
		for _, note in ipairs(self.notes) do
			note.selected = note.selecting
			if not note.selected then
				selectedNotesMap[note.startNote] = nil
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

	for p, vp, notes in layerData:iter(editorModel:getIterRange()) do
		for column, note in pairs(notes) do
			local note = notesMap[note] or
				selectedNotesMap[note] or
				self:newNote(note, editorModel, column)
			table.insert(newNotes, note)
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
