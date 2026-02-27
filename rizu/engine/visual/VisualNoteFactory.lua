local class = require("class")
local ShortVisualNote = require("rizu.engine.visual.ShortVisualNote")
local LongVisualNote = require("rizu.engine.visual.LongVisualNote")

local ResourceFinder = require("rizu.files.ResourceFinder")
local path_util = require("path_util")

---@class rizu.VisualNoteFactory
---@operator call: rizu.VisualNoteFactory
local VisualNoteFactory = class()

---@type {[notechart.NoteType]: string}
local types = {
	tap = "short",
	hold = "long",
	laser = "long",
	drumroll = "long",
	mine = "SoundNote",
	shade = "SoundNote",
	fake = "SoundNote",
	sample = "SoundNote",
	sprite = "ImageNote",
}

---@param visual_info rizu.VisualInfo
function VisualNoteFactory:new(visual_info)
	self.visual_info = visual_info
end

---@param linked_note ncdk2.LinkedNote
---@return rizu.VisualNote?
function VisualNoteFactory:getNote(linked_note)
	local Note = linked_note:isShort() and ShortVisualNote or LongVisualNote
	local visual_note = Note(linked_note, self.visual_info)

	local _type = types[linked_note:getType()]
	if _type == "ImageNote" then
		local images = linked_note.startNote.data.images
		local image = images and images[1]
		if image then
			local _, ext = path_util.name_ext(image[1])
			if ResourceFinder:getFormat(ext) == "video" then
				_type = "VideoNote"
			end
		end
	end
	visual_note.type = _type or visual_note.type

	return visual_note
end

return VisualNoteFactory

