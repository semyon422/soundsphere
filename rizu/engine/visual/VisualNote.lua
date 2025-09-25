local class = require("class")

---@alias rizu.VisualNoteType "short"|"long"

---@class rizu.VisualNote
---@operator call: rizu.VisualNote
---@field cvp ncdk2.VisualPoint
---@field visual ncdk2.Visual
---@field type rizu.VisualNoteType
local VisualNote = class()

---@param linked_note ncdk2.LinkedNote
---@param visual_info rizu.VisualInfo
function VisualNote:new(linked_note, visual_info)
	self.linked_note = linked_note
	self.visual_info = visual_info
end

function VisualNote:update() end

---@return rizu.LogicNote?
function VisualNote:getInputNote()
	return self.visual_info.logic_notes[self.linked_note]
end

---@return string
function VisualNote:getState()
	local input_note = self:getInputNote()
	return input_note and input_note.state or "clear"
end

---@return number?
function VisualNote:getPressedTime()
	local input_note = self:getInputNote()
	return input_note and input_note.pressed_time
end

---@param vp ncdk2.IVisualPoint
---@return number
function VisualNote:getVisualTime(vp)
	if self.visual_info.const then
		return vp.point.absoluteTime
	end
	return vp:getVisualTime(self.cvp)
end

---@param a rizu.VisualNote
---@param b rizu.VisualNote
function VisualNote.__lt(a, b)
	return a.linked_note:getStartTime() < b.linked_note:getStartTime()
end

return VisualNote
