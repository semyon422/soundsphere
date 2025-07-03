local class = require("class")

---@class rizu.PhysicInputEvent
---@operator call: rizu.PhysicInputEvent
---@field device rizu.InputDevice
local PhysicInputEvent = class()

---@param device rizu.InputDevice
function PhysicInputEvent:new(device)
	self.device = device
end

return PhysicInputEvent
