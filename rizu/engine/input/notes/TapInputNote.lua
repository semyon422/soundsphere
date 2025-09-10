local InputNote = require("rizu.engine.input.notes.InputNote")

---@alias rizu.TapInputNoteState "clear"|"missed"|"passed"

---@class rizu.ManiaTapInputNote: rizu.InputNote
---@operator call: rizu.ManiaTapInputNote
local ManiaTapInputNote = InputNote + {}

---@param note ncdk2.LinkedNote
---@param input_info rizu.InputInfo
function ManiaTapInputNote:new(note, input_info)
	assert(note:getType() == "tap")
	assert(note:isShort())

	InputNote.new(self, note, input_info)
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
	return self.input_info:sub(self.note:getStartTime())
end

---@return number
function ManiaTapInputNote:getStartTime()
	return self.note:getStartTime() + self.input_info.timing_values:getMinTime("ShortNote") * self.input_info.rate
end

---@return number
function ManiaTapInputNote:getEndTime()
	return self.note:getEndTime() + self.input_info.timing_values:getMaxTime("ShortNote") * self.input_info.rate
end

---@return sea.TimingResult
function ManiaTapInputNote:getResult()
	local dt = self:getDeltaTime()
	return self.input_info.timing_values:hit("ShortNote", dt)
end

---@param state rizu.TapInputNoteState
function ManiaTapInputNote:switchState(state)
	local old_state = self.state
	self.state = state

	local last_time = self.input_info.timing_values:getMaxTime("ShortNote")
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

ManiaTapInputNote.__lt = InputNote.__lt

return ManiaTapInputNote
