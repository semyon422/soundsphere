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
			if key == "notechart" then
				self:findNotechart()
			elseif key == "modifiers" and not mpModel:isHost() then
				self.modifierModel:setConfig(value)
				self.configModel.configs.modifier = value
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
				self.modifierModel:setConfig(modifiers)
				self.configModel.configs.modifier = modifiers
			end
			if not mpModel.room.isFreeNotechart then
				self.selectModel:setConfig(mpModel.noteChartItem)
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
	local noteChartSetLibrary = self.selectModel.noteChartSetLibrary
	noteChartSetLibrary:findNotechart(mpModel.notechart.hash or "", mpModel.notechart.index or 0)
	local items = noteChartSetLibrary.items

	local selectModel = self.selectModel
	self.selectModel:setLock(false)

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
