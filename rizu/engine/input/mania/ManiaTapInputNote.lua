local ManiaInputNote = require("rizu.engine.input.mania.ManiaInputNote")

---@alias rizu.ManiaTapInputNoteState "clear"|"missed"|"passed"

---@class rizu.ManiaTapInputNote: rizu.ManiaInputNote
---@operator call: rizu.ManiaTapInputNote
local ManiaTapInputNote = ManiaInputNote + {}

---@param note ncdk2.LinkedNote
---@param timing_values sea.TimingValues
---@param time_info rizu.TimeInfo
function ManiaTapInputNote:new(note, timing_values, time_info)
	assert(note:getType() == "tap")
	assert(note:isShort())

	ManiaInputNote.new(self, note, timing_values, time_info)
end

---@return boolean
function ManiaTapInputNote:isActive()
	return self.state == "clear"
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
	local delta_time = math.min(self:getDeltaTime(), last_time)

	-- send to event score engine

	self.observable:send({
		delta_time = delta_time,
		old_state = old_state,
		new_state = state,
	})

	if not self.pressedTime and state == "passed" then
		-- self.pressedTime = currentTime
	end
	if self.pressedTime and state ~= "passed" then
		-- self.pressedTime = nil
	end
end

ManiaTapInputNote.__lt = ManiaInputNote.__lt

return ManiaTapInputNote
