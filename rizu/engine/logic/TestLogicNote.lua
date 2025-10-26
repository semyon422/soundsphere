local LogicNote = require("rizu.engine.logic.notes.LogicNote")

---@class rizu.TestLogicNote: rizu.LogicNote
---@operator call: rizu.TestLogicNote
local TestLogicNote = LogicNote + {}

TestLogicNote.active = true
TestLogicNote.current_time = 0
TestLogicNote.time = 0
TestLogicNote.early_window = -1
TestLogicNote.late_window = 1
TestLogicNote.priority = 0

---@type any
TestLogicNote.data = nil

function TestLogicNote:new()
	self.linked_note = {}
end

---@return boolean
function TestLogicNote:isActive()
	return self.active
end

---@return rizu.LogicNotePos
function TestLogicNote:getPos()
	local t = self.current_time
	if t < self:getStartTime() then
		return "early"
	elseif t > self:getEndTime() then
		return "late"
	end
	return "now"
end

---@return integer
function TestLogicNote:getPriority()
	return self.priority
end

---@param value any
function TestLogicNote:input(value) end

function TestLogicNote:update() end

---@return number
function TestLogicNote:getDeltaTime()
	return self.current_time - self.time
end

---@return number
function TestLogicNote:getStartTime()
	return self.time + self.early_window
end

---@return number
function TestLogicNote:getEndTime()
	return self.time + self.late_window
end

---@param a rizu.LogicNote
---@param b rizu.LogicNote
---@return boolean
function TestLogicNote.__lt(a, b)
	return a:getStartTime() < b:getStartTime()
end

return TestLogicNote
