local LogicNote = require("rizu.engine.logic.notes.LogicNote")

---@alias rizu.TapLogicNoteState "clear"|"missed"|"passed"

---@class rizu.TapLogicNote: rizu.LogicNote
---@operator call: rizu.TapLogicNote
local TapLogicNote = LogicNote + {}

---@param note ncdk2.LinkedNote
---@param logic_info rizu.LogicInfo
function TapLogicNote:new(note, logic_info)
	assert(note:getType() == "tap")
	assert(note:isShort())

	LogicNote.new(self, note, logic_info)
end

---@return boolean
function TapLogicNote:isActive()
	return self.state == "clear"
end

---@param value any
function TapLogicNote:input(value)
	if not value then
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

function TapLogicNote:update()
	local result = self:getResult()
	if result == "too late" then
		self:switchState("missed")
	end
end

---@return number
function TapLogicNote:getStartTime()
	return self.note:getStartTime() + self.logic_info.timing_values:getMinTime("ShortNote") * self.logic_info.rate
end

---@return number
function TapLogicNote:getEndTime()
	return self.note:getEndTime() + self.logic_info.timing_values:getMaxTime("ShortNote") * self.logic_info.rate
end

---@return sea.TimingResult
function TapLogicNote:getResult()
	local dt = self:getDeltaTime()
	return self.logic_info.timing_values:hit("ShortNote", dt)
end

---@param state rizu.TapLogicNoteState
function TapLogicNote:switchState(state)
	local old_state = self.state
	self.state = state

	local last_time = self.logic_info.timing_values:getMaxTime("ShortNote")
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

TapLogicNote.__lt = LogicNote.__lt

return TapLogicNote
