local class = require("class")

---@class sea.MultiplayerUserServerRemote: sea.IMultiplayerServerRemote
---@operator call: sea.MultiplayerUserServerRemote
local MultiplayerUserServerRemote = class()

---@param mp_server sea.MultiplayerServer
function MultiplayerUserServerRemote:new(mp_server)
	self.mp_server = mp_server
end

---@param chartplay_computed sea.ChartplayComputed
function MultiplayerUserServerRemote:setChartplayComputed(chartplay_computed) end

function MultiplayerUserServerRemote:switchReady() end

---@param found boolean
function MultiplayerUserServerRemote:setNotechartFound(found) end

---@param is_playing boolean
function MultiplayerUserServerRemote:setPlaying(is_playing) end

---@param replay_base sea.ReplayBase
function MultiplayerUserServerRemote:setReplayBase(replay_base) end

---@param chartview table
function MultiplayerUserServerRemote:setChartview(chartview) end

---@param msg string
function MultiplayerUserServerRemote:sendMessage(msg)
	self.mp_server:sendLocalMessage(self.user, msg)
end

return MultiplayerUserServerRemote
