local class = require("class")

---@class rizu.IInputNote
---@operator call: rizu.IInputNote
local IInputNote = class()

---@return boolean
function IInputNote:isActive()
	error("not implemented")
end

---@return integer
function IInputNote:getPriority()
	error("not implemented")
end

---@param event rizu.VirtualInputEvent
---@return boolean
function IInputNote:match(event)
	error("not implemented")
end

---@param event rizu.VirtualInputEvent
function IInputNote:receive(event)
	error("not implemented")
end

---@param event rizu.VirtualInputEvent
---@return boolean
function IInputNote:catch(event)
	error("not implemented")
end

function IInputNote:update()
	error("not implemented")
end

---@return boolean
function IInputNote:isReachable()
	error("not implemented")
end

---@return number
function IInputNote:getDeltaTime()
	error("not implemented")
end

---@param a rizu.IInputNote
---@param b rizu.IInputNote
---@return boolean
function IInputNote.__lt(a, b)
	error("not implemented")
end

return IInputNote
