local Observable		= require("aqua.util.Observable")
local NoteChartList  	= require("sphere.screen.select.NoteChartList")
local NoteChartSetList	= require("sphere.screen.select.NoteChartSetList")
local PreviewManager	= require("sphere.screen.select.PreviewManager")
local SearchLine		= require("sphere.screen.select.SearchLine")
local Cache				= require("sphere.database.Cache")
local json				= require("json")

local NoteChartStateManager = {}

NoteChartStateManager.searchString = ""
NoteChartStateManager.path = "userdata/selectedChart.json"

NoteChartStateManager.init = function(self)
	self.observable = Observable:new()

	NoteChartList.observable:add(self)
	NoteChartSetList.observable:add(self)

	self.selectedChart = {1, 1}
end

NoteChartStateManager.load = function(self)
	if love.filesystem.exists(self.path) then
		local file = io.open(self.path, "r")
		self.selectedChart = json.decode(file:read("*all"))
		file:close()

		local chartSetData = Cache:getNoteChartSetEntryById(self.selectedChart[1])
		local chartData = Cache:getNoteChartEntryById(self.selectedChart[2])

		local itemIndex = NoteChartSetList:getItemIndex(chartSetData)
		NoteChartSetList:quickScrollToItemIndex(itemIndex)
		NoteChartSetList:send({
			sender = NoteChartSetList,
			action = "scrollTarget",
			itemIndex = itemIndex,
			list = NoteChartSetList
		})
		NoteChartSetList:calculateButtons()

		local itemIndex = NoteChartList:getItemIndex(chartData)
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
			local entry = NoteChartSetList.items[event.itemIndex].entry
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
			local entry = NoteChartList.items[event.itemIndex].noteChartEntry
			if entry and event.itemIndex == NoteChartList.focusedItemIndex then
				self:send({
					sender = self,
					action = "playNoteChart",
					entry = entry
				})
			end
		end
	elseif sender == NoteChartSetList and action == "return" then
		local entry = NoteChartList.items[NoteChartList.focusedItemIndex].noteChartEntry
		if entry then
			self:send({
				sender = self,
				action = "playNoteChart",
				entry = entry
			})
		end
	elseif action == "scrollTarget" then
		if sender == NoteChartSetList then
			local item = NoteChartSetList.items[event.itemIndex]
			if not item then return end
			
			local list = Cache:getNoteChartsAtSet(item.entry.id)
			if list and list[1] then
				local focusedItem = NoteChartList.items[NoteChartList.focusedItemIndex]
				local entry = focusedItem and focusedItem.entry
				
				NoteChartList.chartSetId = item.entry.id
				NoteChartList:selectCache()
				
				local itemIndex = NoteChartList:getItemIndex(entry)
				NoteChartList:quickScrollToItemIndex(itemIndex)

				NoteChartList:send({
					sender = NoteChartList,
					action = "scrollTarget",
					itemIndex = itemIndex,
					list = NoteChartList
				})
			end

			self.noteChartSetCacheData = item.entry
			self.selectedChart[1] = item.entry.id
		elseif sender == NoteChartList then
			local item = NoteChartList.items[event.itemIndex]

			-- NoteChartList.noteChartCacheData = item.noteChartEntry
			self.selectedChart[2] = item.noteChartEntry.id

			self:send({
				sender = self,
				action = "updateMetaData",
				entry = item.noteChartDataEntry
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
		local entry = focusedItem and focusedItem.entry
		
		NoteChartSetList:selectCache()
		
		NoteChartSetList:quickScrollToItemIndex(NoteChartSetList:getItemIndex(entry))
		NoteChartSetList:sendState()
	end
end

return NoteChartStateManager
