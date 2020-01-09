local Observable		= require("aqua.util.Observable")
local NoteChartList  	= require("sphere.screen.select.NoteChartList")
local NoteChartSetList	= require("sphere.screen.select.NoteChartSetList")
local PreviewManager	= require("sphere.screen.select.PreviewManager")
local SearchLine		= require("sphere.screen.select.SearchLine")
local Cache				= require("sphere.database.Cache")

local NoteChartStateManager = {}

NoteChartStateManager.searchString = ""

NoteChartStateManager.init = function(self)
	self.observable = Observable:new()

	NoteChartList.observable:add(self)
	NoteChartSetList.observable:add(self)
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
			local cacheData = NoteChartSetList.items[event.itemIndex].cacheData
			if cacheData and event.itemIndex == NoteChartSetList.focusedItemIndex then
				local NoteChartMenu	= require("sphere.screen.select.NoteChartMenu")
				NoteChartMenu:show()
			end
		elseif sender == NoteChartList and event.button == 1 then
			local cacheData = NoteChartList.items[event.itemIndex].cacheData
			if cacheData and event.itemIndex == NoteChartList.focusedItemIndex then
				self:send({
					sender = self,
					action = "playNoteChart",
					cacheData = cacheData
				})
			end
		end
	elseif sender == NoteChartSetList and action == "return" then
		local cacheData = NoteChartList.items[NoteChartList.focusedItemIndex].cacheData
		if cacheData then
			self:send({
				sender = self,
				action = "playNoteChart",
				cacheData = cacheData
			})
		end
	elseif action == "scrollTarget" then
		if sender == NoteChartSetList then
			local item = NoteChartSetList.items[event.itemIndex]
			local list = Cache.chartsAtSet[item.cacheData.id]
			if list and list[1] then
				local focusedItem = NoteChartList.items[NoteChartList.focusedItemIndex]
				local cacheData = focusedItem and focusedItem.cacheData
				
				NoteChartList.chartSetId = item.cacheData.id
				NoteChartList:selectCache()
				
				local itemIndex = NoteChartList:getItemIndex(cacheData)
				NoteChartList:quickScrollToItemIndex(itemIndex)

				NoteChartList:send({
					sender = NoteChartList,
					action = "scrollTarget",
					itemIndex = itemIndex,
					list = NoteChartList
				})
			end

			self.noteChartSetCacheData = item.cacheData
		elseif sender == NoteChartList then
			local item = NoteChartList.items[event.itemIndex]

			NoteChartList.noteChartCacheData = item.cacheData

			self:send({
				sender = self,
				action = "updateMetaData",
				cacheData = item.cacheData
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
		local cacheData = focusedItem and focusedItem.cacheData
		
		NoteChartSetList:selectCache()
		
		NoteChartSetList:quickScrollToItemIndex(NoteChartSetList:getItemIndex(cacheData))
		NoteChartSetList:sendState()
	end
end

return NoteChartStateManager
