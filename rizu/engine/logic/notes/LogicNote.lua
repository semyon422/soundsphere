local class = require("class")
local Observable = require("Observable")

---@alias rizu.LogicNoteState "clear"|"missed"|"passed"

---@class rizu.LogicNote
---@operator call: rizu.LogicNote
local LogicNote = class()

LogicNote.is_bottom = false

---@param note ncdk2.LinkedNote
---@param logic_info rizu.LogicInfo
function LogicNote:new(note, logic_info)
	self.note = note
	self.logic_info = logic_info

	self.observable = Observable()

	self:reset()
end

function LogicNote:reset()
	self.state = "clear"
end

---@return boolean
function LogicNote:isActive()
	error("not implemented")
end

---@return integer
function LogicNote:getPriority()
	if self.state == "clear" then
		return 0
	end
	return -1
end

---@return "early"|"now"|"late"
function LogicNote:getPos()
	error("not implemented")
end

---@param value any
---@return boolean? catched
function LogicNote:input(value)
	error("not implemented")
end

function LogicNote:update()
	error("not implemented")
end

---@return number
function LogicNote:getDeltaTime()
	return self.logic_info:sub(self.note:getStartTime())
end

---@return number
function LogicNote:getStartTime()
	error("not implemented")
end

---@param state string
function LogicNote:switchState(state)
	error("not implemented")
end

---@param a rizu.LogicNote
---@param b rizu.LogicNote
---@return boolean
function LogicNote.__lt(a, b)
	return a:getStartTime() < b:getStartTime()
end

return LogicNote
