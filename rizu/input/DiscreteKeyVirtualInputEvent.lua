local VirtualInputEvent = require("rizu.input.VirtualInputEvent")

---@class rizu.DiscreteKeyVirtualInputEvent: rizu.VirtualInputEvent
---@operator call: rizu.DiscreteKeyVirtualInputEvent
local DiscreteKeyVirtualInputEvent = VirtualInputEvent + {}

---@param key string
---@param state boolean
function DiscreteKeyVirtualInputEvent:new(key, state)
	self.key = key
	self.state = state
end

return DiscreteKeyVirtualInputEvent
