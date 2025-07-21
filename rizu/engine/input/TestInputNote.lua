local IInputNote = require("rizu.engine.input.IInputNote")

---@class rizu.TestInputNote: rizu.IInputNote
---@operator call: rizu.TestInputNote
local TestInputNote = IInputNote + {}

TestInputNote.active = false
TestInputNote.current_time = 0
TestInputNote.time = 0
TestInputNote.early_window = -1
TestInputNote.late_window = 1
TestInputNote.priority = 0

---@return boolean
function TestInputNote:isActive()
	return self.active
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

---@return boolean
function TestInputNote:isReachable()
	return self.current_time >= self:getStartTime()
end

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

---@param a rizu.IInputNote
---@param b rizu.IInputNote
---@return boolean
function TestInputNote.__lt(a, b)
	return a:getStartTime() < b:getStartTime()
end

return TestInputNote
