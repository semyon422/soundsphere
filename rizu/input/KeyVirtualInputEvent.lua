local VirtualInputEvent = require("rizu.input.VirtualInputEvent")

---@class rizu.KeyVirtualInputEvent: rizu.VirtualInputEvent
---@operator call: rizu.KeyVirtualInputEvent
local KeyVirtualInputEvent = VirtualInputEvent + {}

KeyVirtualInputEvent.id = 1
KeyVirtualInputEvent.type = "absolute"

---@param pos ncdk2.Column
---@param value boolean
function KeyVirtualInputEvent:new(pos, value)
	self.pos = pos
	self.value = value
end

return KeyVirtualInputEvent
