local FileFinder = require("sphere.persistence.FileFinder")
local ShortGraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.ShortGraphicalNote")
local LongGraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.LongGraphicalNote")
local ImageNote = require("sphere.models.RhythmModel.GraphicEngine.ImageNote")

local GraphicalNoteFactory = {}

---@param note notechart.Note
---@return string
local function getImageNoteType(note)
	local image = note.images[1]
	if image and FileFinder:getType(image) == "video" then
		return "VideoNote"
	end
	return "ImageNote"
end

local notes = {
	ShortNote = {ShortGraphicalNote, "ShortNote"},
	LongNoteStart = {LongGraphicalNote, "LongNote"},
	LaserNoteStart = {LongGraphicalNote, "LongNote"},
	LineNoteStart = {LongGraphicalNote, "LongNote"},
	SoundNote = {ShortGraphicalNote, "SoundNote"},
	ImageNote = {ImageNote, getImageNoteType},
}

---@param note notechart.Note
---@return sphere.GraphicalNote?
function GraphicalNoteFactory:getNote(note)
	local classAndType = notes[note.noteType]
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
