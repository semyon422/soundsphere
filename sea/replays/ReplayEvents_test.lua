local ReplayEvents = require("sea.replays.ReplayEvents")

local test = {}

---@param t testing.T
function test.all(t)
	local events = {
		{0, 1, true},
		{1, 2, true},
		{2, 1, false},
		{3, 2, false},
	}

	local data = t:assert(ReplayEvents.encode(events))
	if not data then
		return
	end

	local _events = t:assert(ReplayEvents.decode(data))
	if not _events then
		return
	end

	t:tdeq(_events, events)
end

return test
