local Observable = require("Observable")
local IInputNote = require("rizu.engine.input.IInputNote")
local DiscreteKeyVirtualInputEvent = require("rizu.input.DiscreteKeyVirtualInputEvent")

---@alias rizu.ManiaInputNoteState "clear"|"missed"|"passed"

---@class rizu.ManiaInputNote: rizu.IInputNote
---@operator call: rizu.ManiaInputNote
local ManiaInputNote = IInputNote + {}

---@param note ncdk2.LinkedNote
---@param input_info rizu.InputInfo
function ManiaInputNote:new(note, input_info)
	self.note = note
	self.input_info = input_info

	self.observable = Observable()

	self:reset()
end

function ManiaInputNote:reset()
	self.state = "clear"
end

---@return boolean
function ManiaInputNote:isActive()
	error("not implemented")
end

---@return integer
function ManiaInputNote:getPriority()
	if self.state == "clear" then
		return 0
	end
	return -1
end

---@param event rizu.VirtualInputEvent
---@return boolean
function ManiaInputNote:match(event)
	if not DiscreteKeyVirtualInputEvent * event then
		return false
	end
	---@cast event rizu.DiscreteKeyVirtualInputEvent
	return event.key == self.note:getColumn()
end

---@param event rizu.DiscreteKeyVirtualInputEvent
function ManiaInputNote:receive(event)
	error("not implemented")
end

function ManiaInputNote:update()
	error("not implemented")
end

---@return number
function ManiaInputNote:getDeltaTime()
	return self.input_info:sub(self.note:getStartTime())
end

---@return number
function ManiaInputNote:getStartTime()
	error("not implemented")
end

---@return number
function ManiaInputNote:getEndTime()
	error("not implemented")
end

---@return sea.TimingResult
function ManiaInputNote:getResult()
	error("not implemented")
end

---@param state string
function ManiaInputNote:switchState(state)
	error("not implemented")
end

---@param a rizu.IInputNote
---@param b rizu.IInputNote
---@return boolean
function ManiaInputNote.__lt(a, b)
	return a:getStartTime() < b:getStartTime()
end

return ManiaInputNote
