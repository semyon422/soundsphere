local class = require("class")

---@class rizu.InputNote
---@operator call: rizu.InputNote
local InputNote = class()

InputNote.active = false
InputNote.time = 0
InputNote.early_window = -1
InputNote.late_window = 1

---@return boolean
function InputNote:isActive()
	return self.active
end

---@param event rizu.VirtualInputEvent
---@return boolean
function InputNote:match(event)
	return false
end

---@param event rizu.VirtualInputEvent
function InputNote:receive(event) end

---@param event rizu.VirtualInputEvent
---@return boolean
function InputNote:catch(event)
	return false
end

---@param time number
function InputNote:update(time) end

---@param time number
---@return boolean
function InputNote:isReachable(time)
	return time >= self:getStartTime()
end

---@param time number
---@return number
function InputNote:getDeltaTime(time)
	return time - self.time
end

--- earliest point
---@return number
function InputNote:getStartTime()
	return self.time + self.early_window
end

--- latest point
---@return number
function InputNote:getEndTime()
	return self.time + self.late_window
end

return InputNote
