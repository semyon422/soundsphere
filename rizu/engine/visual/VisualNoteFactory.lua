local class = require("class")
local ShortVisualNote = require("rizu.engine.visual.ShortVisualNote")
local LongVisualNote = require("rizu.engine.visual.LongVisualNote")

---@class rizu.VisualNoteFactory
---@operator call: rizu.VisualNoteFactory
local VisualNoteFactory = class()

---@param visual_info rizu.VisualInfo
function VisualNoteFactory:new(visual_info)
	self.visual_info = visual_info
end

---@param linked_note ncdk2.LinkedNote
---@return rizu.VisualNote?
function VisualNoteFactory:getNote(linked_note)
	local Note = linked_note:isShort() and ShortVisualNote or LongVisualNote
	return Note(linked_note, self.visual_info)
end

return VisualNoteFactory

