local class = require("class")

---@class sea.RoomServerRemote: sea.IMultiplayerServerRemote
---@operator call: sea.RoomServerRemote
local RoomServerRemote = class()

---@param mp_server sea.MultiplayerServer
function RoomServerRemote:new(mp_server)
	self.mp_server = mp_server
end

---@param rules table
function RoomServerRemote:setRules(rules) end

---@param chartmeta_key table
function RoomServerRemote:setChartmetaKey(chartmeta_key) end

---@param replay_base sea.ReplayBase
function RoomServerRemote:setReplayBase(replay_base) end

---@param user_id any
function RoomServerRemote:setHost(user_id) end

---@param user_id any
function RoomServerRemote:kickUser(user_id) end

function RoomServerRemote:startMatch() end

function RoomServerRemote:stopMatch() end

return RoomServerRemote
