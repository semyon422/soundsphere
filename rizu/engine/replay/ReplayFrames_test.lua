local ReplayFrames = require("rizu.engine.replay.ReplayFrames")
local VirtualInputEvent = require("rizu.input.VirtualInputEvent")
local InputMode = require("ncdk.InputMode")

local test = {}

---@param t testing.T
function test.all(t)
	local input_mode = InputMode("4key")

	---@type rizu.ReplayFrame[]
	local events = {
		{time = 0, event = VirtualInputEvent(1, false, "key1")},
		{time = 1, event = VirtualInputEvent(2, true, nil, {1, 2})},
		{time = math.pi, event = VirtualInputEvent(2, "left", "key2", {math.pi, 0})},
		{time = 2, event = VirtualInputEvent(2)},
	}

	local s = ReplayFrames.encode(events, input_mode)
	local _events = ReplayFrames.decode(s, input_mode)

	t:tdeq(_events, events)
end

return test
