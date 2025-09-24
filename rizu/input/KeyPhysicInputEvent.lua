local PhysicInputEvent = require("rizu.input.PhysicInputEvent")

---@class rizu.KeyPhysicInputEvent: rizu.PhysicInputEvent
---@operator call: rizu.KeyPhysicInputEvent
local KeyPhysicInputEvent = PhysicInputEvent + {}

---@param device rizu.InputDevice
---@param key string
---@param state boolean true - pressed, false - released
function KeyPhysicInputEvent:new(device, key, state)
	self.device = device
	self.key = key
	self.state = state
end

return KeyPhysicInputEvent
