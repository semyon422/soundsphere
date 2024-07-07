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
	return self.editorModel.point.absoluteTime
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

---@param note ncdk2.Note
---@return sphere.LogicalNote?
function GraphicEngine:getLogicalNote(note)
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
		self.selectedNotes[note.startNote] = note
		return
	end
	if not keepOthers then
		return
	end
	note.selected = false
	self.selectedNotes[note.startNote] = nil
end

---@param _note ncdk2.Note
---@param column ncdk2.Column
---@return sphere.EditorNote?
function GraphicEngine:newNote(_note, column)
	local note = EditorNoteFactory:newNote(_note.noteType)
	if not note then
		return
	end
	note.startNote = _note
	note.editorModel = self.editorModel
	note.graphicEngine = self
	note.layerData = self.editorModel.layer
	note.column = column
	return note
end

function GraphicEngine:update()
	local editorModel = self.editorModel
	local layer = editorModel.layer

	local selectedNotes = self.selectedNotes

	local notesMap = {}
	for _, note in ipairs(self.notes) do
		notesMap[note.startNote] = note
		if note.selecting then
			note.selected = true
			selectedNotes[note.startNote] = note
		elseif self.selecting then
			note.selected = false
			selectedNotes[note.startNote] = nil
		end
	end

	local newNotes = {}
	self.notes = newNotes

	for _note, column in layer.notes:iter(editorModel:getIterRange()) do
		local note = notesMap[_note] or
			selectedNotes[_note] or
			self:newNote(_note, column)
		if note then
			table.insert(newNotes, note)
			note:update()
		end
	end
end

return GraphicEngine
