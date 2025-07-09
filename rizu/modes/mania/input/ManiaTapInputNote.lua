local InputNote = require("rizu.modes.common.input.InputNote")

---@alias rizu.ManiaTapInputNoteState "clear"|"missed"|"passed"

---@class rizu.ManiaTapInputNote: rizu.InputNote
local ManiaTapInputNote = InputNote + {}

ManiaTapInputNote.active = true
ManiaTapInputNote.state = "clear"

---@param note ncdk2.LinkedNote
---@param timing_values sea.TimingValues
function ManiaTapInputNote:new(note, timing_values)
	assert(note:getType() == "tap")
	assert(note:isShort())
	self.note = note
	self.timing_values = timing_values
end

---@param event rizu.DiscreteKeyVirtualInputEvent
---@return boolean
function ManiaTapInputNote:match(event)
	return event.key == self.note:getColumn()
end

---@param event rizu.DiscreteKeyVirtualInputEvent
function ManiaTapInputNote:receive(event)
	--
end

---@param time number
function ManiaTapInputNote:update(time)
	--
end

---@param time number
---@param rate number
---@return number
function ManiaTapInputNote:getDeltaTime(time, rate)
	return (time - self.note:getStartTime()) / rate
end

---@return number
function ManiaTapInputNote:getStartTime()
	return self.note:getStartTime() + self.timing_values:getMinTime("ShortNote")
end

---@return number
function ManiaTapInputNote:getEndTime()
	return self.note:getEndTime() + self.timing_values:getMaxTime("ShortNote")
end

---@param time number
---@param rate number
---@return sea.TimingResult
function ManiaTapInputNote:getResult(time, rate)
	local dt = self:getDeltaTime(time, rate)
	return self.timing_values:hit("ShortNote", dt)
end

---@param time number
---@param rate number
---@param result sea.TimingResult
function ManiaTapInputNote:processResult(result, time, rate)
	local keyState = self.keyState
	if keyState and result == "too early" then
		self:switchState("clear", time, rate)
		self.keyState = false
	elseif keyState and (result == "early" or result == "late") or result == "too late" then
		self:switchState("missed", time, rate)
		self:next()
	elseif keyState and result == "exactly" then
		self:switchState("passed", time, rate)
		self:next()
	end
end

---@param time number
---@param rate number
---@param state rizu.ManiaTapInputNoteState
function ManiaTapInputNote:switchState(state, time, rate)
	local old_state = self.state
	self.state = state

	local last_time = self.timing_values:getMaxTime("ShortNote")
	local last_time_full = self:getEndTime()

	local currentTime = math.min(time, last_time_full)
	local deltaTime = math.min(self:getDeltaTime(time, rate), last_time)

	-- send to event score engine

	if not self.pressedTime and state == "passed" then
		self.pressedTime = currentTime
	end
	if self.pressedTime and state ~= "passed" then
		self.pressedTime = nil
	end
end

return ManiaTapInputNote
