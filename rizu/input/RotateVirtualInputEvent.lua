local VirtualInputEvent = require("rizu.input.VirtualInputEvent")

---@class rizu.RotateVirtualInputEvent: rizu.VirtualInputEvent
---@operator call: rizu.RotateVirtualInputEvent
local RotateVirtualInputEvent = VirtualInputEvent + {}

RotateVirtualInputEvent.id = 1
RotateVirtualInputEvent.type = "relative"

---@param pos ncdk2.Column
---@param value number
function RotateVirtualInputEvent:new(pos, value)
	self.pos = pos
	self.value = value
end

return RotateVirtualInputEvent
