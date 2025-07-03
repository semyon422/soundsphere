local PhysicInputEvent = require("rizu.input.PhysicInputEvent")

---@class rizu.DiscreteKeyPhysicInputEvent: rizu.PhysicInputEvent
---@operator call: rizu.DiscreteKeyPhysicInputEvent
local DiscreteKeyPhysicInputEvent = PhysicInputEvent + {}

---@param device rizu.InputDevice
---@param key string
---@param state boolean true - pressed, false - released
function DiscreteKeyPhysicInputEvent:new(device, key, state)
	self.device = device
	self.key = key
	self.state = state
end

return DiscreteKeyPhysicInputEvent
