local CoordinateManager		= require("aqua.graphics.CoordinateManager")
local Observable			= require("aqua.util.Observable")
local Cache					= require("sphere.database.Cache")
local SearchManager			= require("sphere.database.SearchManager")
local ScreenManager			= require("sphere.screen.ScreenManager")
local GameplayScreen		= require("sphere.screen.gameplay.GameplayScreen")
local CacheList				= require("sphere.screen.select.CacheList")
local NoteChartListButton	= require("sphere.screen.select.NoteChartListButton")
local PreviewManager		= require("sphere.screen.select.PreviewManager")
local SearchLine			= require("sphere.screen.select.SearchLine")

local NoteChartList = CacheList:new()

NoteChartList.sender = "NoteChartList"

NoteChartList.buttonCount = 9
NoteChartList.middleOffset = 5
NoteChartList.startOffset = 5
NoteChartList.endOffset = 5

NoteChartList.basePath = "?"
NoteChartList.chartSetId = 0
NoteChartList.needItemsSort = true

NoteChartList.Button = NoteChartListButton

NoteChartList.send = function(self, event)
	if event.action == "scrollStop" then
		local item = self.items[event.itemIndex]
		local cacheData = item and item.cacheData
		if cacheData then
			self:updateBackground()
			self:updateAudio()
		end
	elseif event.action == "buttonInteract" and event.button == 1 or event.action == "return" then
		local cacheData = self.items[event.itemIndex].cacheData
		if cacheData then
			PreviewManager:stop()
			GameplayScreen.cacheData = cacheData
			ScreenManager:set(GameplayScreen)
		end
	elseif event.action == "scrollTarget" then
		local item = self.items[event.itemIndex]
		if item and item.cacheData then
			self:send({
				sender = self.sender,
				action = "updateMetaData",
				cacheData = item.cacheData
			})
		end
	end
	
	return CacheList.send(self, event)
end

NoteChartList.receive = function(self, event)
	if event.action == "scrollTarget" then
		local item = event.list.items[event.itemIndex]
		if item and item.cacheData and event.list.sender == "NoteChartSetList" then
			local focusedItem = self.items[self.focusedItemIndex]
			local cacheData = focusedItem and focusedItem.cacheData
			
			self.chartSetId = item.cacheData.id
			self:selectCache()
			self:unloadButtons()
			self:calculateButtons()
			
			local itemIndex = self:getItemIndex(cacheData)
			self.focusedItemIndex = itemIndex
			self.visualItemIndex = itemIndex
			self:send({
				sender = self.sender,
				action = "scrollTarget",
				list = self,
				itemIndex = itemIndex
			})
			self:send({
				sender = self.sender,
				action = "scrollStop"
			})
		end
	elseif event.name == "keypressed" then
		local key = event.args[1]
		if key == "lctrl" or key == "rctrl" then
			self.keyControl = true
		end
	elseif event.name == "keyreleased" then
		local key = event.args[1]
		if key == "lctrl" or key == "rctrl" then
			self.keyControl = false
		end
	end
	
	return CacheList.receive(self, event)
end

NoteChartList.sortItemsFunction = function(a, b)
	a, b = a.cacheData, b.cacheData
	if
		#a.inputMode < #b.inputMode or
		#a.inputMode == #b.inputMode and a.inputMode < b.inputMode or
		a.inputMode == b.inputMode and a.noteCount / a.length < b.noteCount / b.length
	then
		return true
	end
end

NoteChartList.getItemName = function(self, cacheData)
	return cacheData.name or "."
end

NoteChartList.selectCache = function(self)
	local items = {}
	
	local list = Cache.chartsAtSet[self.chartSetId]
	if not list or not list[1] then
		return
	end
	local foundList = SearchManager:search(list, SearchLine.searchTable)
	for i = 1, #foundList do
		items[#items + 1] = self:getItem(foundList[i])
	end
	
	if self.needItemsSort then
		table.sort(items, self.sortItemsFunction)
	end
	
	return self:setItems(items)
end

return NoteChartList
