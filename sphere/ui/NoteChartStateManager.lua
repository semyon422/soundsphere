local Observable		= require("aqua.util.Observable")
local ScoreList		  	= require("sphere.ui.ScoreList")
local NoteChartList  	= require("sphere.ui.NoteChartList")
local NoteChartSetList	= require("sphere.ui.NoteChartSetList")
local PreviewManager	= require("sphere.ui.PreviewManager")
-- local InputManager		= require("sphere.screen.gameplay.InputManager")
-- local ReplayManager		= require("sphere.screen.gameplay.ReplayManager")
-- local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local CacheManager		= require("sphere.database.CacheManager")
local json				= require("json")
local GameConfig		= require("sphere.config.GameConfig")

local NoteChartStateManager = {}

NoteChartStateManager.searchString = ""

NoteChartStateManager.init = function(self)
	self.observable = Observable:new()

	ScoreList.observable:add(self)
	NoteChartList.observable:add(self)
	NoteChartSetList.observable:add(self)
end

NoteChartStateManager.load = function(self)
	local noteChartSetEntry = self.noteChartModel.noteChartSetEntry
	local noteChartEntry = self.noteChartModel.noteChartEntry

	local itemIndex = NoteChartSetList:getItemIndex(noteChartSetEntry)
	NoteChartSetList:quickScrollToItemIndex(itemIndex)
	NoteChartSetList:send({
		sender = NoteChartSetList,
		action = "scrollTarget",
		itemIndex = itemIndex,
		list = NoteChartSetList
	})
	NoteChartSetList:calculateButtons()

	local itemIndex = NoteChartList:getItemIndex(noteChartEntry)
	NoteChartList:quickScrollToItemIndex(itemIndex)
	NoteChartList:calculateButtons()
end

NoteChartStateManager.unload = function(self)
end

NoteChartStateManager.send = function(self, event)
	return self.observable:send(event)
end

NoteChartStateManager.receive = function(self, event)
	local sender = event.sender
	local action = event.action

	if action == "scrollStop" and (sender == NoteChartSetList or sender == NoteChartList) then
		NoteChartList:updateBackground()
		NoteChartList:updateAudio()
	elseif action == "buttonInteract" then
		if sender == NoteChartSetList and event.button == 2 then
			local entry = NoteChartSetList.items[event.itemIndex].noteChartSetEntry
			if entry and event.itemIndex == NoteChartSetList.focusedItemIndex then
				local NoteChartMenu	= require("sphere.ui.NoteChartMenu")
				NoteChartMenu:show()
			end
		elseif sender == NoteChartList and event.button == 2 then
			local entry = NoteChartList.items[event.itemIndex].noteChartEntry
			if entry and event.itemIndex == NoteChartList.focusedItemIndex then
				love.system.setClipboardText(entry.path)
			end
		elseif sender == NoteChartList and event.button == 1 then
			local item = NoteChartList.items[event.itemIndex]
			local noteChartEntry = item.noteChartEntry
			if noteChartEntry and event.itemIndex == NoteChartList.focusedItemIndex then
				self:send({
					sender = self,
					action = "playNoteChart"
				})
			end
		elseif sender == ScoreList and (event.button == 1 or event.button == 2) then
			local item = ScoreList.items[event.itemIndex]
			local noteChartListItem = NoteChartList.items[NoteChartList.focusedItemIndex]
			local noteChartEntry = noteChartListItem.noteChartEntry
			if noteChartEntry and event.itemIndex == ScoreList.focusedItemIndex then
				local mode
				if event.button == 1 then
					if love.keyboard.isDown("lshift") then
						mode = "result"
					else
						mode = "replay"
					end
				elseif event.button == 2 then
					mode = "retry"
				end
				self:send({
					sender = self,
					action = "replayNoteChart",
					mode = mode,
					scoreEntry = item.scoreEntry
				})
			end
		end
	elseif sender == NoteChartSetList and action == "return" then
		local noteChartEntry = NoteChartList.items[NoteChartList.focusedItemIndex].noteChartEntry
		if noteChartEntry then
			self:send({
				sender = self,
				action = "playNoteChart",
			})
		end
	elseif action == "scrollTarget" then
		if sender == NoteChartSetList then
			local item = NoteChartSetList.items[event.itemIndex]
			if not item then return end

			local list = CacheManager:getNoteChartsAtSet(item.noteChartSetEntry.id)
			if list and list[1] then
				local focusedItem = NoteChartList.items[NoteChartList.focusedItemIndex]
				local noteChartEntry = focusedItem and focusedItem.noteChartEntry

				NoteChartList.setId = item.noteChartSetEntry.id
				NoteChartList:selectCache()

				local itemIndex = NoteChartList:getItemIndex(noteChartEntry)
				NoteChartList:quickScrollToItemIndex(itemIndex)

				NoteChartList:send({
					sender = NoteChartList,
					action = "scrollTarget",
					itemIndex = itemIndex,
					list = NoteChartList
				})
			end

			self.noteChartSetEntry = item.noteChartSetEntry

			self.observable:send({
				name = "selectNoteChart",
				type = "noteChartSetEntry",
				id = item.noteChartSetEntry.id
			})
		elseif sender == NoteChartList then
			local item = NoteChartList.items[event.itemIndex]
			if not item then return end

			self.observable:send({
				name = "selectNoteChart",
				type = "noteChartEntry",
				id = item.noteChartEntry.id
			})

			self:send({
				sender = self,
				action = "updateMetaData"
			})
		end
	elseif event.name == "search" then
		local searchLine = event.sender
		if event.text == "" then
			NoteChartSetList.needSearch = false
		else
			NoteChartSetList.needSearch = true
		end

		self.searchString = event.text
		NoteChartSetList.searchString = event.text
		NoteChartList.searchString = event.text

		local focusedItem = NoteChartSetList.items[NoteChartSetList.focusedItemIndex]
		local noteChartSetEntry = focusedItem and focusedItem.noteChartSetEntry

		NoteChartSetList:selectCache()

		NoteChartSetList:quickScrollToItemIndex(NoteChartSetList:getItemIndex(noteChartSetEntry))
		NoteChartSetList:sendState()
	elseif event.name == "keypressed" and event.args[1] == GameConfig:get("select.selectRandomNoteChartSet") then
		NoteChartSetList:quickScrollToItemIndex(math.random(1, #NoteChartSetList.items))
		NoteChartSetList:sendState()
	end
end

NoteChartStateManager:init()

return NoteChartStateManager
