local ReplayCoder = require("sea.replays.ReplayCoder")
local InputMode = require("ncdk.InputMode")

local test = {}

---@param t testing.T
function test.all(t)
	local replay = {
		version = 2,
		frames = {},
	}

	local data = t:assert(ReplayCoder.encode(replay))
	if not data then
		return
	end

	t:eq(data, '{"events":"aGVsbG8="}')

	local _replay = t:assert(ReplayCoder.decode(data))
	if not _replay then
		return
	end

	t:tdeq(_replay, replay)
end

return test
