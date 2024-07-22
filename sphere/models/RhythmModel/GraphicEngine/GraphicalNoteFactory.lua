local FileFinder = require("sphere.persistence.FileFinder")
local ShortGraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.ShortGraphicalNote")
local LongGraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.LongGraphicalNote")
local ImageNote = require("sphere.models.RhythmModel.GraphicEngine.ImageNote")

local GraphicalNoteFactory = {}

---@param note ncdk2.LinkedNote
---@return string
local function getImageNoteType(note)
	local image = note.startNote.images[1]
	if image and FileFinder:getType(image[1]) == "video" then
		return "VideoNote"
	end
	return "ImageNote"
end

local notes = {
	note = {ShortGraphicalNote, "ShortNote"},
	hold = {LongGraphicalNote, "LongNote"},
	laser = {LongGraphicalNote, "LongNote"},
	drumroll = {LongGraphicalNote, "LongNote"},
	mine = {ShortGraphicalNote, "SoundNote"},
	shade = {ShortGraphicalNote, "ShortNote"},
	fake = {ShortGraphicalNote, "SoundNote"},
	sample = {ShortGraphicalNote, "SoundNote"},
	sprite = {ImageNote, getImageNoteType},
}

---@param note ncdk2.LinkedNote
---@return sphere.GraphicalNote?
function GraphicalNoteFactory:getNote(note)
	local classAndType = notes[note:getType()]
	if not classAndType then
		return
	end

	local noteType = classAndType[2]
	if type(noteType) == "function" then
		noteType = noteType(note)
	end

	return classAndType[1](noteType, note)
end

return GraphicalNoteFactory
