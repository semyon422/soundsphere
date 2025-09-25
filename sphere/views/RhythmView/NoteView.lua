local class = require("class")
local NotePartView = require("sphere.views.RhythmView.NotePartView")

---@class sphere.NoteView
---@operator call: sphere.NoteView
---@field noteSkin sphere.NoteSkin
---@field graphicalNote rizu.VisualNote
---@field column number
---@field chords table
local NoteView = class()

---@param noteType string
function NoteView:new(noteType)
	self.noteType = noteType
	self.startChord = {}
	self.endChord = {}
	self.middleChord = {}
end

local noteParts = {}

---@param name string
---@return sphere.NotePartView
function NoteView:getNotePart(name)
	local part = noteParts[name]
	if not part then
		part = NotePartView({name = name})
		noteParts[name] = part
	end
	part.noteView = self
	return part
end

---@param quad love.Quad?
---@param ... number
---@return love.Quad|number?
---@return number?...
function NoteView:getDraw(quad, ...)
	if quad then
		return quad, ...
	end
	return ...
end

function NoteView:draw() end

---@return boolean
function NoteView:isVisible()
	return true
end

return NoteView
