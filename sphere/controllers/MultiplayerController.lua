local Class = require("aqua.util.Class")
local table_util = require("aqua.table_util")
local remote = require("aqua.util.remote")

local MultiplayerController = Class:new()

MultiplayerController.load = function(self)
	local mpModel = self.game.multiplayerModel
	mpModel.handlers = {
		set = function(peer, key, value)
			mpModel[key] = value
			if key == "notechart" then
				self:findNotechart()
			elseif key == "modifiers" and not mpModel:isHost() then
				self.game.modifierModel:setConfig(value)
				self.game.configModel.configs.modifier = value
				mpModel.modifiers = table_util.deepcopy(value)
			elseif key == "roomUsers" then
				for _, user in ipairs(value) do
					if user.peerId == mpModel.user.peerId then
						mpModel.user = user
						break
					end
				end
			end
		end,
		startMatch = function(peer)
			if mpModel.isPlaying or not mpModel.noteChartItem then
				return
			end
			if not mpModel.room.isFreeModifiers then
				local modifiers = table_util.deepcopy(mpModel.modifiers)
				self.game.modifierModel:setConfig(modifiers)
				self.game.configModel.configs.modifier = modifiers
			end
			if not mpModel.room.isFreeNotechart then
				self.game.selectModel:setConfig(mpModel.noteChartItem)
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
	local mpModel = self.game.multiplayerModel
	self.game.noteChartSetLibraryModel:findNotechart(mpModel.notechart.hash or "", mpModel.notechart.index or 0)
	local items = self.game.noteChartSetLibraryModel.items

	local selectModel = self.game.selectModel

	mpModel.downloadingBeatmap = nil
	local item = items[1]
	if item then
		mpModel.noteChartItem = {
			setId = item.setId,
			noteChartId = item.noteChartId,
			noteChartDataId = item.noteChartDataId,
		}
		selectModel:setConfig(item)
		selectModel:pullNoteChartSet(true)
		mpModel.peer.setNotechartFound(true)
		return
	end
	selectModel:setConfig({
		setId = 0,
		noteChartId = 0,
		noteChartDataId = 0,
	})
	mpModel.noteChartItem = nil
	selectModel:pullNoteChartSet(true)
	mpModel.peer.setNotechartFound(false)
end)

MultiplayerController.unload = function(self)
	self.game.multiplayerModel:unload()
end

MultiplayerController.update = function(self)
	self.game.multiplayerModel:update()
end

return MultiplayerController
