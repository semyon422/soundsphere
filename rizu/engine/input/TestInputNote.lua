local InputNote = require("rizu.engine.input.notes.InputNote")

---@class rizu.TestInputNote: rizu.InputNote
---@operator call: rizu.TestInputNote
local TestInputNote = InputNote + {}

TestInputNote.current_time = 0
TestInputNote.time = 0
TestInputNote.early_window = -1
TestInputNote.late_window = 1
TestInputNote.priority = 0

---@return "early"|"now"|"late"
function TestInputNote:getPos()
	local t = self.current_time
	if t < self:getStartTime() then
		return "early"
	elseif t > self:getEndTime() then
		return "late"
	end
	return "now"
end

---@return integer
function TestInputNote:getPriority()
	return self.priority
end

---@param event rizu.VirtualInputEvent
---@return boolean
function TestInputNote:match(event)
	return false
end

---@param event rizu.VirtualInputEvent
function TestInputNote:receive(event) end

---@param event rizu.VirtualInputEvent
---@return boolean
function TestInputNote:catch(event)
	return false
end

function TestInputNote:update() end

---@return number
function TestInputNote:getDeltaTime()
	return self.current_time - self.time
end

---@return number
function TestInputNote:getStartTime()
	return self.time + self.early_window
end

---@return number
function TestInputNote:getEndTime()
	return self.time + self.late_window
end

---@param a rizu.InputNote
---@param b rizu.InputNote
---@return boolean
function TestInputNote.__lt(a, b)
	return a:getStartTime() < b:getStartTime()
end

return TestInputNote
