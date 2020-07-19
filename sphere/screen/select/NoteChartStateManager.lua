local Observable		= require("aqua.util.Observable")
local ScoreList		  	= require("sphere.screen.select.ScoreList")
local NoteChartList  	= require("sphere.screen.select.NoteChartList")
local NoteChartSetList	= require("sphere.screen.select.NoteChartSetList")
local PreviewManager	= require("sphere.screen.select.PreviewManager")
local InputManager		= require("sphere.screen.gameplay.InputManager")
local ReplayManager		= require("sphere.screen.gameplay.ReplayManager")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local CacheManager		= require("sphere.database.CacheManager")
local json				= require("json")
local GameConfig		= require("sphere.config.GameConfig")

local NoteChartStateManager = {}

NoteChartStateManager.searchString = ""
NoteChartStateManager.path = "userdata/selectedChart.json"

NoteChartStateManager.init = function(self)
	self.observable = Observable:new()

	ScoreList.observable:add(self)
	NoteChartList.observable:add(self)
	NoteChartSetList.observable:add(self)

	self.selectedChart = {1, 1}
end

NoteChartStateManager.load = function(self)
	if love.filesystem.exists(self.path) then
		local file = io.open(self.path, "r")
		self.selectedChart = json.decode(file:read("*all"))
		file:close()

		local noteChartSetEntry = CacheManager:getNoteChartSetEntryById(self.selectedChart[1])
		local noteChartEntry = CacheManager:getNoteChartEntryById(self.selectedChart[2])

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
end

NoteChartStateManager.unload = function(self)
	local file = io.open(self.path, "w")
	file:write(json.encode(self.selectedChart))
	return file:close()
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
				local NoteChartMenu	= require("sphere.screen.select.NoteChartMenu")
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
			local noteChartDataEntry = item.noteChartDataEntry
			if noteChartEntry and event.itemIndex == NoteChartList.focusedItemIndex then
				InputManager:setMode("external")
				ReplayManager:setMode("record")
				self:send({
					sender = self,
					action = "playNoteChart",
					noteChartEntry = noteChartEntry,
					noteChartDataEntry = noteChartDataEntry
				})
			end
		elseif sender == ScoreList and (event.button == 1 or event.button == 2) then
			local item = ScoreList.items[event.itemIndex]
			local noteChartListItem = NoteChartList.items[NoteChartList.focusedItemIndex]
			local noteChartEntry = noteChartListItem.noteChartEntry
			local noteChartDataEntry = noteChartListItem.noteChartDataEntry
			if noteChartEntry and event.itemIndex == ScoreList.focusedItemIndex then
				local replay = ReplayManager:loadReplay(item.scoreEntry.replayHash)
				if replay.modifiers then
					ModifierManager:getSequence():fromJson(replay.modifiers)
				end
				if event.button == 1 then
					ReplayManager.replay = replay
					InputManager:setMode("internal")
					ReplayManager:setMode("replay")
				else
					InputManager:setMode("external")
					ReplayManager:setMode("record")
				end
				self:send({
					sender = self,
					action = "playNoteChart",
					noteChartEntry = noteChartEntry,
					noteChartDataEntry = noteChartDataEntry,
					replay = replay,
					fastPlay = event.button == 1 and love.keyboard.isDown("lshift")
				})
			end
		end
	elseif sender == NoteChartSetList and action == "return" then
		local noteChartEntry = NoteChartList.items[NoteChartList.focusedItemIndex].noteChartEntry
		local noteChartDataEntry = NoteChartList.items[NoteChartList.focusedItemIndex].noteChartDataEntry
		if noteChartEntry then
			self:send({
				sender = self,
				action = "playNoteChart",
				noteChartEntry = noteChartEntry,
				noteChartDataEntry = noteChartDataEntry
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
			self.selectedChart[1] = item.noteChartSetEntry.id
		elseif sender == NoteChartList then
			local item = NoteChartList.items[event.itemIndex]
			if not item then return end
			
			self.selectedChart[2] = item.noteChartEntry.id

			self:send({
				sender = self,
				action = "updateMetaData",
				noteChartDataEntry = item.noteChartDataEntry
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
