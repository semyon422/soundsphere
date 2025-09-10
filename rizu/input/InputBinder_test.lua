local InputBinder = require("rizu.input.InputBinder")
local InputDevice = require("rizu.input.InputDevice")
local DiscreteKeyPhysicInputEvent = require("rizu.input.DiscreteKeyPhysicInputEvent")

local test = {}

---@param t testing.T
function test.all(t)
	local config = {}
	local binder = InputBinder(config, "4key")
	local device = InputDevice("keyboard", 1)

	local event = binder:transform(DiscreteKeyPhysicInputEvent(device, "d", true))
	t:assert(not event)

	binder:setKey("key1", 1, "d", device)
	t:assert(binder:getKey("key1", 1))
	t:assert(not binder:getKey("key1", 2))

	event = binder:transform(DiscreteKeyPhysicInputEvent(device, "d", true))
	t:tdeq(event, {pos = "key1", value = true})

	binder:setKey("key1", 1)

	event = binder:transform(DiscreteKeyPhysicInputEvent(device, "d", true))
	t:assert(not event)
end

return test
