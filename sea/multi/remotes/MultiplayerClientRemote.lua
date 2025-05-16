local class = require("class")

---@class sea.MultiplayerClientRemote
---@operator call: sea.MultiplayerClientRemote
local MultiplayerClientRemote = class()

---@param client sea.MultiplayerClient
function MultiplayerClientRemote:new(client)
	self.client = client
end

---@param ... any
function MultiplayerClientRemote:print(...)
	print(...)
end

---@param key any
---@param value any
function MultiplayerClientRemote:set(key, value)
	self.client:set(key, value)
end

function MultiplayerClientRemote:startMatch()
	local mp_model = self.mp_model

	if mp_model.isPlaying or not mp_model.chartview then
		return
	end

	mp_model:setIsPlaying(true)

	local room = mp_model.room
	if not room or not mp_model:isHost() then
		return
	end

	if not room.is_free_notechart then
		-- self.selectModel:setConfig(mp_model.chartview)  -- mp controller
	end
	if not room.is_free_modifiers then
		mp_model.replayBase.modifiers = room.modifiers
	end
	if not room.is_free_const then
		mp_model.replayBase.const = room.const
	end
	if not room.is_free_rate then
		mp_model.replayBase.rate = room.rate
	end
end

function MultiplayerClientRemote:stopMatch()
	local client = self.client
	if client.is_playing then
		client:setPlaying(false)
	end
end

---@param msg string
function MultiplayerClientRemote:addMessage(msg)
	self.client:addMessage(msg)
end

return MultiplayerClientRemote
