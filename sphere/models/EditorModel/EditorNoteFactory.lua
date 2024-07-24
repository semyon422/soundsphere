local class = require("class")
local ShortEditorNote = require("sphere.models.EditorModel.ShortEditorNote")
local LongEditorNote = require("sphere.models.EditorModel.LongEditorNote")

---@class sphere.EditorNoteFactory
---@operator call: sphere.EditorNoteFactory
local EditorNoteFactory = class()

local notes = {
	note = {ShortEditorNote, "ShortNote"},
	hold = {LongEditorNote, "LongNote"},
	laser = {LongEditorNote, "LongNote"},
	drumroll = {LongEditorNote, "LongNote"},
	mine = {ShortEditorNote, "SoundNote"},
	shade = {ShortEditorNote, "SoundNote"},
	fake = {ShortEditorNote, "SoundNote"},
	sample = {ShortEditorNote, "SoundNote"},
	-- sprite = {ShortEditorNote, "SoundNote"},
}

---@param note ncdk2.LinkedNote
---@return sphere.EditorNote?
function EditorNoteFactory:newNote(note)
	local classAndType = notes[note:getType()]
	if not classAndType then
		return
	end

	return classAndType[1](classAndType[2], note)
end

return EditorNoteFactory
