local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")
local ChartplayComputed = require("sea.chart.ChartplayComputed")
local ReplayBase = require("sea.replays.ReplayBase")

---@class sea.MultiplayerUserServerRemoteValidation: sea.MultiplayerUserServerRemote
---@operator call: sea.MultiplayerUserServerRemoteValidation
local MultiplayerUserServerRemoteValidation = class()

---@param remote sea.MultiplayerUserServerRemote
function MultiplayerUserServerRemoteValidation:new(remote)
	self.remote = remote
end

---@param chartplay_computed sea.ChartplayComputed
function MultiplayerUserServerRemoteValidation:setChartplayComputed(chartplay_computed)
	assert(valid.format(ChartplayComputed.validate(chartplay_computed)))
	self.remote:setChartplayComputed(chartplay_computed)
end

function MultiplayerUserServerRemoteValidation:switchReady()
	self.remote:switchReady()
end

---@param found boolean
function MultiplayerUserServerRemoteValidation:setChartFound(found)
	assert(types.boolean(found))
	self.remote:setChartFound(found)
end

---@param is_playing boolean
function MultiplayerUserServerRemoteValidation:setPlaying(is_playing)
	assert(types.boolean(is_playing))
	self.remote:setPlaying(is_playing)
end

---@param replay_base sea.ReplayBase
function MultiplayerUserServerRemoteValidation:setReplayBase(replay_base)
	assert(valid.format(ReplayBase.validate(replay_base)))
	self.remote:setReplayBase(replay_base)
end

---@param msg string
function MultiplayerUserServerRemoteValidation:sendMessage(msg)
	assert(types.string(msg))
	self.remote:sendMessage(msg)
end

return MultiplayerUserServerRemoteValidation
