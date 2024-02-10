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
				self.playContext.modifiers = value
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
			if mpModel.isPlaying or not mpModel.chartview then
				return
			end
			if not mpModel.room.isFreeModifiers then
				local modifiers = table_util.deepcopy(mpModel.modifiers)
				self.playContext.modifiers = modifiers
				self.configModel.configs.modifier = modifiers
			end
			if not mpModel.room.isFreeNotechart then
				self.selectModel:setConfig(mpModel.chartview)
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

	selectModel:findNotechart(mpModel.notechart.hash or "", mpModel.notechart.index or 0)
	local items = selectModel.noteChartSetLibrary.items

	selectModel:setLock(false)

	mpModel.downloadingBeatmap = nil
	local item = items[1]
	if item then
		mpModel.chartview = {
			chartfile_set_id = item.chartfile_set_id,
			chartfile_id = item.chartfile_id,
			chartmeta_id = item.chartmeta_id,
		}
		selectModel:setConfig(item)
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
