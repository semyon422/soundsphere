local class = require("class")

---@class sea.MultiplayerUserServerRemoteValidation: sea.MultiplayerUserServerRemote
---@operator call: sea.MultiplayerUserServerRemoteValidation
local MultiplayerUserServerRemoteValidation = class()

---@param remote sea.MultiplayerUserServerRemote
function MultiplayerUserServerRemoteValidation:new(remote)
	self.remote = remote
end

---@param chartplay_computed sea.ChartplayComputed
function MultiplayerUserServerRemoteValidation:setChartplayComputed(chartplay_computed)
	self.remote:setChartplayComputed(chartplay_computed)
end

function MultiplayerUserServerRemoteValidation:switchReady()
	self.remote:switchReady()
end

---@param found boolean
function MultiplayerUserServerRemoteValidation:setChartFound(found)
	self.remote:setChartFound(found)
end

---@param is_playing boolean
function MultiplayerUserServerRemoteValidation:setPlaying(is_playing)
	self.remote:setPlaying(is_playing)
end

---@param replay_base sea.ReplayBase
function MultiplayerUserServerRemoteValidation:setReplayBase(replay_base)
	self.remote:setReplayBase(replay_base)
end

---@param chartview table
function MultiplayerUserServerRemoteValidation:setChartview(chartview)
	self.remote:setChartview(chartview)
end

---@param msg string
function MultiplayerUserServerRemoteValidation:sendMessage(msg)
	self.remote:sendMessage(msg)
end

return MultiplayerUserServerRemoteValidation
