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

		local chartSetData = Cache.chartSetDict[self.selectedChart[1]]
		local chartData = Cache.chartDict[self.selectedChart[2]]

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
			local cacheData = NoteChartSetList.items[event.itemIndex].cacheData
			if cacheData and event.itemIndex == NoteChartSetList.focusedItemIndex then
				local NoteChartMenu	= require("sphere.screen.select.NoteChartMenu")
				NoteChartMenu:show()
			end
		elseif sender == NoteChartList and event.button == 2 then
			local cacheData = NoteChartList.items[event.itemIndex].cacheData
			if cacheData and event.itemIndex == NoteChartList.focusedItemIndex then
				love.system.setClipboardText(cacheData.path)
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
			if not item then return end
			
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
			self.selectedChart[1] = item.cacheData.id
		elseif sender == NoteChartList then
			local item = NoteChartList.items[event.itemIndex]

			NoteChartList.noteChartCacheData = item.cacheData
			self.selectedChart[2] = item.cacheData.id

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
