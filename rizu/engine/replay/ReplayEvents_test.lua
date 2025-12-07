local ReplayEvents = require("rizu.engine.replay.ReplayEvents")
local VirtualInputEvent = require("rizu.input.VirtualInputEvent")
local InputMode = require("ncdk.InputMode")

local test = {}

---@param t testing.T
function test.all(t)
	local input_mode = InputMode("4key")

	---@type rizu.ReplayEvent[]
	local events = {
		{0, VirtualInputEvent(1, false, "key1")},
		{1, VirtualInputEvent(2, true, nil, {1, 2})},
		{math.pi, VirtualInputEvent(2, "left", "key2", {math.pi, 0})},
		{2, VirtualInputEvent(2)},
	}

	local s = ReplayEvents.encode(events, input_mode)
	local _events = ReplayEvents.decode(s, input_mode)

	t:tdeq(_events, events)
end

return test
