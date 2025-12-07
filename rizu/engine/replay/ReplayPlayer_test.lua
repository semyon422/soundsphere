local ReplayPlayer = require("rizu.engine.replay.ReplayPlayer")
local VirtualInputEvent = require("rizu.input.VirtualInputEvent")

local test = {}

---@param t testing.T
function test.all(t)
	---@type rizu.ReplayEvent[]
	local events = {
		{0, VirtualInputEvent(0)},
		{1, VirtualInputEvent(1)},
		{2, VirtualInputEvent(3)},
		{4, VirtualInputEvent(4)},
	}

	local p = ReplayPlayer(events)

	t:tdeq({p:play(-1)}, {})
	t:tdeq({p:play(1)}, events[1])
	t:tdeq({p:play(1)}, events[2])
	t:tdeq({p:play(1)}, {})
	t:tdeq({p:play(10)}, events[3])
	t:tdeq({p:play(10)}, events[4])
	t:tdeq({p:play(10)}, {})
end

return test
