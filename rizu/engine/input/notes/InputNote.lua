local class = require("class")

---@class rizu.InputNote
---@operator call: rizu.InputNote
local InputNote = class()

InputNote.is_bottom = false

---@param note rizu.LogicNote
function InputNote:new(note)
	self.logic_note = note
end

---@return integer
function InputNote:getPriority()
	return self.logic_note.state == "clear" and 0 or -1
end

---@param event rizu.VirtualInputEvent
---@return boolean
function InputNote:match(event)
	return self.logic_note.linked_note:getColumn() == event.column
end

---@param value any
function InputNote:input(value)
	self.logic_note:input(value)
end

---@return number
function InputNote:getDeltaTime()
	return self.logic_note:getDeltaTime()
end

return InputNote
