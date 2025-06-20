local class = require("class")
local types = require("sea.shared.types")

---@class sea.MultiplayerUserServerRemote: sea.IMultiplayerServerRemote
---@operator call: sea.MultiplayerUserServerRemote
local MultiplayerUserServerRemote = class()

---@param mp_server sea.MultiplayerServer
function MultiplayerUserServerRemote:new(mp_server)
	self.mp_server = mp_server
end

---@param chartplay_computed sea.ChartplayComputed
function MultiplayerUserServerRemote:setChartplayComputed(chartplay_computed)
	self.mp_server:setChartplayComputed(self.user, chartplay_computed)
end

function MultiplayerUserServerRemote:switchReady()
	self.mp_server:switchReady(self.user)
end

---@param found boolean
function MultiplayerUserServerRemote:setChartFound(found)
	if not types.boolean(found) then
		return nil, "invalid found"
	end
	self.mp_server:setChartFound(self.user, found)
	return true
end

---@param is_playing boolean
function MultiplayerUserServerRemote:setPlaying(is_playing) end

---@param replay_base sea.ReplayBase
function MultiplayerUserServerRemote:setReplayBase(replay_base) end

---@param msg string
function MultiplayerUserServerRemote:sendMessage(msg)
	self.mp_server:sendLocalMessage(self.user, msg)
end

return MultiplayerUserServerRemote
