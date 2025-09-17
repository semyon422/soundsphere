local table_util = require("table_util")
local LogicNote = require("rizu.engine.logic.notes.LogicNote")

---@alias rizu.HoldLogicNoteState
---| "clear"
---| "startMissed"
---| "endMissed"
---| "startMissedPressed"
---| "startPassedPressed"
---| "endPassed"
---| "endMissedPassed"

---@type {[rizu.HoldLogicNoteState]: integer}
local active_states = table_util.invert({
	"clear",
	"startMissed",
	"startMissedPressed",
	"startPassedPressed",
})

---@class rizu.HoldLogicNote: rizu.LogicNote
---@operator call: rizu.HoldLogicNote
local HoldLogicNote = LogicNote + {}

---@param note ncdk2.LinkedNote
---@param logic_info rizu.LogicInfo
function HoldLogicNote:new(note, logic_info)
	assert(note:getType() == "hold")
	assert(note:isLong())

	LogicNote.new(self, note, logic_info)
end

---@return boolean
function HoldLogicNote:isActive()
	return not not active_states[self.state]
end

---@param value any
function HoldLogicNote:input(value)
	local start_result = self:getStartResult()
	local end_result = self:getEndResult()

	local state = self.state

	if value then
		if state == "clear" then
			if start_result == "too early" then
				self:switchState("clear")
			elseif start_result == "early" or start_result == "late" then
				self:switchState("startMissedPressed")
			elseif start_result == "exactly" then
				self:switchState("startPassedPressed")
			end
		elseif state == "startMissed" then
			self:switchState("startMissedPressed")
		end
	else
		if state == "startPassedPressed" then
			if end_result == "too early" then
				self:switchState("startMissed")
			elseif end_result == "early" or end_result == "late" then
				self:switchState("endMissed")
			elseif end_result == "exactly" then
				self:switchState("endPassed")
			end
		elseif state == "startMissedPressed" then
			if end_result == "too early" then
				self:switchState("startMissed")
			elseif end_result == "early" or end_result == "late" then
				self:switchState("endMissed")
			elseif end_result == "exactly" then
				self:switchState("endMissedPassed")
			end
		end
	end
end

function HoldLogicNote:update()
	local start_result = self:getStartResult()
	local end_result = self:getEndResult()

	if self.state == "clear" and start_result == "too late" then
		self:switchState("startMissed")
	end

	if self:isActive() and end_result == "too late" then
		self:switchState("endMissed")
	end
end

---@return number
function HoldLogicNote:getEndDeltaTime()
	return self.logic_info:sub(self.note:getEndTime())
end

---@return number
function HoldLogicNote:getStartTime()
	return self.note:getStartTime() + self.logic_info.timing_values:getMinTime("LongNoteStart") * self.logic_info.rate
end

---@return number
function HoldLogicNote:getEndTime()
	return self.note:getEndTime() + self.logic_info.timing_values:getMaxTime("LongNoteEnd") * self.logic_info.rate
end

---@return sea.TimingResult
function HoldLogicNote:getStartResult()
	local dt = self:getDeltaTime()
	return self.logic_info.timing_values:hit("LongNoteStart", dt)
end

---@return sea.TimingResult
function HoldLogicNote:getEndResult()
	local dt = self:getEndDeltaTime()
	return self.logic_info.timing_values:hit("LongNoteEnd", dt)
end

---@param state rizu.HoldLogicNoteState
function HoldLogicNote:switchState(state)
	local old_state = self.state
	self.state = state

	local start_last_time = self.logic_info.timing_values:getMaxTime("LongNoteStart")
	local end_last_time = self.logic_info.timing_values:getMaxTime("LongNoteEnd")

	local delta_time = 0
	if old_state == "clear" then
		delta_time = math.min(self:getDeltaTime(), start_last_time)
	else
		delta_time = math.min(self:getEndDeltaTime(), end_last_time)
	end

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

HoldLogicNote.__lt = LogicNote.__lt

return HoldLogicNote
