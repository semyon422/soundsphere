local class = require("class")
local Observable = require("Observable")
local KeyVirtualInputEvent = require("rizu.input.KeyVirtualInputEvent")

---@alias rizu.InputNoteState "clear"|"missed"|"passed"

---@class rizu.InputNote
---@operator call: rizu.InputNote
local InputNote = class()

---@param note ncdk2.LinkedNote
---@param input_info rizu.InputInfo
function InputNote:new(note, input_info)
	self.note = note
	self.input_info = input_info

	self.observable = Observable()

	self:reset()
end

function InputNote:reset()
	self.state = "clear"
end

---@return boolean
function InputNote:isActive()
	error("not implemented")
end

---@return integer
function InputNote:getPriority()
	if self.state == "clear" then
		return 0
	end
	return -1
end

---@return "early"|"now"|"late"
function InputNote:getPos()
	error("not implemented")
end

---@param event rizu.VirtualInputEvent
---@return boolean
function InputNote:catch(event)
	error("not implemented")
end

---@param event rizu.VirtualInputEvent
---@return boolean
function InputNote:match(event)
	if KeyVirtualInputEvent * event then
		---@cast event rizu.KeyVirtualInputEvent
		return event.pos == self.note:getColumn()
	end

	return false
end

---@param event rizu.VirtualInputEvent
function InputNote:receive(event)
	error("not implemented")
end

function InputNote:update()
	error("not implemented")
end

---@return number
function InputNote:getDeltaTime()
	return self.input_info:sub(self.note:getStartTime())
end

---@return number
function InputNote:getStartTime()
	error("not implemented")
end

---@return number
function InputNote:getEndTime()
	error("not implemented")
end

---@return sea.TimingResult
function InputNote:getResult()
	error("not implemented")
end

---@param state string
function InputNote:switchState(state)
	error("not implemented")
end

---@param a rizu.InputNote
---@param b rizu.InputNote
---@return boolean
function InputNote.__lt(a, b)
	return a:getStartTime() < b:getStartTime()
end

return InputNote
