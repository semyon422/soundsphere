local IClientPeer = require("sea.access.IClientPeer")

---@class sea.FakeClientPeer: sea.IClientPeer
---@operator call: sea.FakeClientPeer
local FakeClientPeer = IClientPeer + {}

---@param hash string
---@return true?
---@return string?
function FakeClientPeer:requireChartfileData(hash)
	return coroutine.yield(hash)
end

---@param events_hash string
---@return true?
---@return string?
function FakeClientPeer:requireEventsData(events_hash)
	return coroutine.yield(events_hash)
end

return FakeClientPeer
