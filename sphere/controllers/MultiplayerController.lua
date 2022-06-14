local Class = require("aqua.util.Class")
local deepclone = require("aqua.util.deepclone")
local remote = require("aqua.util.remote")

local MultiplayerController = Class:new()

MultiplayerController.load = function(self)
	local mpModel = self.game.multiplayerModel
	mpModel.handlers = {
		set = function(peer, key, value)
			mpModel[key] = value
			if key == "notechart" and not mpModel:isHost() then
				self:findNotechart()
			elseif key == "modifiers" then
				self.game.modifierModel:setConfig(value)
				self.game.configModel.configs.modifier = value
				mpModel.modifiers = deepclone(value)
			end
		end,
		startMatch = function(peer)
			if mpModel.isPlaying or not mpModel.noteChartItem then
				return
			end
			if not mpModel.room.isFreeModifiers then
				local modifiers = deepclone(mpModel.modifiers)
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

	local item = items[1]
	if item then
		mpModel.noteChartItem = {
			setId = item.setId,
			noteChartId = item.noteChartId,
			noteChartDataId = item.noteChartDataId,
		}
		self.game.selectModel:setConfig(item)
		self.game.selectModel:pullNoteChartSet(true)
		mpModel.peer.setNotechartFound(true)
		return
	end
	self.game.selectModel:setConfig({
		setId = 0,
		noteChartId = 0,
		noteChartDataId = 0,
	})
	mpModel.noteChartItem = nil
	self.game.selectModel:pullNoteChartSet(true)
	mpModel.peer.setNotechartFound(false)
end)

MultiplayerController.unload = function(self)
	self.game.multiplayerModel:unload()
end

MultiplayerController.update = function(self)
	self.game.multiplayerModel:update()
end

return MultiplayerController
