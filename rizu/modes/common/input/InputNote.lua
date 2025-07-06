local class = require("class")

---@class rizu.InputNote
---@operator call: rizu.InputNote
local InputNote = class()

---@return boolean
function InputNote:isActive()
	return true
end

---@return boolean
function InputNote:isPlayable()
	return true
end

---@return boolean
function InputNote:match()
	return true
end

---@param time number
---@return boolean
function InputNote:isHere(time)
	return time >= self:getStartTime() and time < self:getEndTime()
end

--- earliest point
---@return number
function InputNote:getStartTime()
	return 0
end

--- latest point
---@return number
function InputNote:getEndTime()
	return 0
end

return InputNote
