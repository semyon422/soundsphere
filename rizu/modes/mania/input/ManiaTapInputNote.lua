local Observable = require("Observable")
local IInputNote = require("rizu.modes.common.input.IInputNote")
local DiscreteKeyVirtualInputEvent = require("rizu.input.DiscreteKeyVirtualInputEvent")

---@alias rizu.ManiaTapInputNoteState "clear"|"missed"|"passed"

---@class rizu.ManiaTapInputNote: rizu.IInputNote
---@operator call: rizu.ManiaTapInputNote
local ManiaTapInputNote = IInputNote + {}

ManiaTapInputNote.state = "clear"

---@param note ncdk2.LinkedNote
---@param timing_values sea.TimingValues
---@param time_info rizu.TimeInfo
function ManiaTapInputNote:new(note, timing_values, time_info)
	assert(note:getType() == "tap")
	assert(note:isShort())

	self.note = note
	self.timing_values = timing_values
	self.time_info = time_info

	self.observable = Observable()
end

---@return boolean
function ManiaTapInputNote:isActive()
	return self.state ~= "clear"
end

---@param event rizu.VirtualInputEvent
---@return boolean
function ManiaTapInputNote:match(event)
	if not DiscreteKeyVirtualInputEvent * event then
		return false
	end
	---@cast event rizu.DiscreteKeyVirtualInputEvent
	return event.key == self.note:getColumn()
end

---@param event rizu.DiscreteKeyVirtualInputEvent
function ManiaTapInputNote:receive(event)
	if not event.state then
		return
	end

	local result = self:getResult()

	if result == "too early" then
		self:switchState("clear")
	elseif result == "early" or result == "late" then
		self:switchState("missed")
	elseif result == "exactly" then
		self:switchState("passed")
	end
end

function ManiaTapInputNote:update()
	local result = self:getResult()
	if result == "too late" then
		self:switchState("missed")
	end
end

---@return number
function ManiaTapInputNote:getDeltaTime()
	return self.time_info:sub(self.note:getStartTime())
end

---@return number
function ManiaTapInputNote:getStartTime()
	return self.note:getStartTime() + self.timing_values:getMinTime("ShortNote") * self.time_info.rate
end

---@return number
function ManiaTapInputNote:getEndTime()
	return self.note:getEndTime() + self.timing_values:getMaxTime("ShortNote") * self.time_info.rate
end

---@return sea.TimingResult
function ManiaTapInputNote:getResult()
	local dt = self:getDeltaTime()
	return self.timing_values:hit("ShortNote", dt)
end

---@param state rizu.ManiaTapInputNoteState
function ManiaTapInputNote:switchState(state)
	local old_state = self.state
	self.state = state

	local last_time = self.timing_values:getMaxTime("ShortNote")
	local last_time_full = self:getEndTime()

	-- local currentTime = math.min(time, last_time_full)
	local deltaTime = math.min(self:getDeltaTime(), last_time)

	-- send to event score engine

	self.observable:send({
		deltaTime = deltaTime,
	})

	if not self.pressedTime and state == "passed" then
		-- self.pressedTime = currentTime
	end
	if self.pressedTime and state ~= "passed" then
		-- self.pressedTime = nil
	end
end

---@param a rizu.IInputNote
---@param b rizu.IInputNote
---@return boolean
function ManiaTapInputNote.__lt(a, b)
	return a:getStartTime() < b:getStartTime()
end

return ManiaTapInputNote
