local class = require("class")

---@class sea.RoomServerRemote: sea.IMultiplayerServerRemote
---@operator call: sea.RoomServerRemote
local RoomServerRemote = class()

---@param mp_server sea.MultiplayerServer
function RoomServerRemote:new(mp_server)
	self.mp_server = mp_server
end

---@param rules sea.RoomRules
function RoomServerRemote:setRules(rules)
	self.mp_server:setLocalRules(self.user, rules)
end

---@param chartmeta_key sea.ChartmetaKey
function RoomServerRemote:setChartmetaKey(chartmeta_key) end

---@param replay_base sea.ReplayBase
function RoomServerRemote:setReplayBase(replay_base) end

---@param user_id any
function RoomServerRemote:setHost(user_id) end

---@param user_id any
function RoomServerRemote:kickUser(user_id) end

function RoomServerRemote:startMatch()
	self.mp_server:startLocalMatch(self.user)
end

function RoomServerRemote:stopMatch() end

return RoomServerRemote
