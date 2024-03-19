local class = require("class")
local table_util = require("table_util")
local remote = require("remote")

---@class sphere.MultiplayerController
---@operator call: sphere.MultiplayerController
local MultiplayerController = class()

function MultiplayerController:load()
	local mpModel = self.multiplayerModel
	mpModel.handlers = {
		set = function(peer, key, value)
			mpModel[key] = value
			if key == "room" then
				if not mpModel:isHost() then
					self:findNotechart()
					self.playContext.modifiers = value.modifiers
					self.playContext.rate = value.rate
					self.playContext.const = value.rate
				end
			end
		end,
		startMatch = function(peer)
			if mpModel.isPlaying or not mpModel.chartview then
				return
			end
			local room = mpModel.room
			if not mpModel:isHost() then
				if not room.is_free_modifiers then
					local modifiers = table_util.deepcopy(room.modifiers)
					self.playContext.modifiers = modifiers
				end
				if not room.is_free_notechart then
					self.selectModel:setConfig(mpModel.chartview)
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
	local selectModel = self.selectModel

	local hash = mpModel.room.notechart.hash or ""
	local index = mpModel.room.notechart.index or 0
	if self.hash == hash and self.index == index then
		return
	end
	self.hash = hash
	self.index = index

	print("find", hash, index)
	selectModel:findNotechart(hash, index)
	local items = selectModel.noteChartSetLibrary.items

	selectModel:setLock(false)

	mpModel.downloadingBeatmap = nil
	local chartview = items[1]
	if chartview then
		mpModel.chartview = chartview
		selectModel:setConfig(chartview)
		selectModel:pullNoteChartSet(true)
		mpModel.peer.setNotechartFound(true)
		return
	end
	selectModel:setConfig({
		chartfile_set_id = 0,
		chartfile_id = 0,
		chartmeta_id = 0,
	})
	mpModel.chartview = nil
	selectModel:pullNoteChartSet(true)
	mpModel.peer.setNotechartFound(false)
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
