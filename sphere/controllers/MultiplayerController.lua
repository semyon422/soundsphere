local class = require("class")
local remote = require("remote")

---@class sphere.MultiplayerController
---@operator call: sphere.MultiplayerController
local MultiplayerController = class()

---@param multiplayerModel sphere.MultiplayerModel
---@param configModel sphere.ConfigModel
---@param selectModel sphere.SelectModel
---@param playContext sphere.PlayContext
function MultiplayerController:new(
	multiplayerModel,
	configModel,
	selectModel,
	playContext
)
	self.multiplayerModel = multiplayerModel
	self.configModel = configModel
	self.selectModel = selectModel
	self.playContext = playContext
end

function MultiplayerController:load()
	local mpModel = self.multiplayerModel
	mpModel.handlers = {
		set = function(peer, key, value)
			mpModel[key] = value
			if key == "room" then
				local room = value
				if not mpModel:isHost() then
					self:findNotechart()
					if not room.is_free_modifiers then
						self.playContext.modifiers = room.modifiers
					end
					if not room.is_free_const then
						self.playContext.const = room.const
					end
					if not room.is_free_rate then
						self.playContext.rate = room.rate
					end
				end
			end
		end,
		startMatch = function(peer)
			if mpModel.isPlaying or not mpModel.chartview then
				return
			end
			local room = mpModel.room
			if not mpModel:isHost() then
				if not room.is_free_notechart then
					self.selectModel:setConfig(mpModel.chartview)
				end
				if not room.is_free_modifiers then
					self.playContext.modifiers = room.modifiers
				end
				if not room.is_free_const then
					self.playContext.const = room.const
				end
				if not room.is_free_rate then
					self.playContext.rate = room.rate
				end
			end
			mpModel:setIsPlaying(true)
		end,
		stopMatch = function(peer)
			if mpModel.isPlaying then
				mpModel:setIsPlaying(false)
			end
		end,
		addMessage = function(peer, message)
			mpModel:addMessage(message)
		end,
	}
	mpModel:load()
end

MultiplayerController.findNotechart = remote.wrap(function(self)
	local mpModel = self.multiplayerModel

	local hash = mpModel.room.notechart.hash or ""
	local index = mpModel.room.notechart.index or 0
	if self.hash == hash and self.index == index then
		return
	end
	self.hash = hash
	self.index = index

	self.multiplayerModel:findNotechartAsync()
end)

function MultiplayerController:beginUnload()
	self.selectModel:setLock(true)
end

function MultiplayerController:unload()
	self.multiplayerModel:unload()
end

function MultiplayerController:update()
	self.multiplayerModel:update()
end

return MultiplayerController
