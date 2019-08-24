local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Observable		= require("aqua.util.Observable")
local Cache				= require("sphere.database.Cache")
local SearchManager		= require("sphere.database.SearchManager")
local ScreenManager		= require("sphere.screen.ScreenManager")
local GameplayScreen	= require("sphere.screen.gameplay.GameplayScreen")
local CacheList			= require("sphere.screen.select.CacheList")
local PreviewManager	= require("sphere.screen.select.PreviewManager")
local SearchLine		= require("sphere.screen.select.SearchLine")
local OverlayMenu		= require("sphere.ui.OverlayMenu")

local NoteChartSetList = CacheList:new()

NoteChartSetList.x = 0.6
NoteChartSetList.y = 0
NoteChartSetList.w = 0.4
NoteChartSetList.h = 1

NoteChartSetList.sender = "NoteChartSetList"

NoteChartSetList.buttonCount = 17
NoteChartSetList.middleOffset = 9
NoteChartSetList.startOffset = 9
NoteChartSetList.endOffset = 9

NoteChartSetList.basePath = "userdata/charts"
NoteChartSetList.keyControl = true
NoteChartSetList.needItemsSort = true
NoteChartSetList.needSearch = false
NoteChartSetList.searchString = ""
NoteChartSetList.searchTable = {}

NoteChartSetList.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
end

NoteChartSetList.send = function(self, event)
	if event.action == "scrollStop" then
		self.NoteChartList:updateBackground()
		self.NoteChartList:updateAudio()
	elseif event.action == "buttonInteract" then
		local cacheData = self.items[event.itemIndex].cacheData
		if event.button == 2 and event.itemIndex == self.focusedItemIndex then
			OverlayMenu:show()
			OverlayMenu:setTitle("Notechart set options")
			OverlayMenu:setItems({
				{
					name = "open folder",
					onClick = function()
						love.system.openURL("file://" .. love.filesystem.getSource() .. "/" .. cacheData.path)
						OverlayMenu:hide()
					end
				},
				{
					name = "recache",
					onClick = function()
						Cache:update(cacheData.path)
						OverlayMenu:hide()
					end
				}
			})
		end
	elseif event.action == "return" then
		local cacheData = self.NoteChartList.items[self.NoteChartList.focusedItemIndex].cacheData
		if cacheData then
			GameplayScreen.cacheData = cacheData
			ScreenManager:set(GameplayScreen)
		end
	elseif event.action == "scrollTarget" then
		local item = self.items[event.itemIndex]
		if item and item.cacheData then
			local list = Cache.chartsAtSet[item.cacheData.id]
			if list and list[1] then
				self:send({
					action = "updateMetaData",
					cacheData = list[1]
				})
			end
		end
	end
	
	return CacheList.send(self, event)
end

NoteChartSetList.receive = function(self, event)
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "lctrl" or key == "rctrl" then
			self.keyControl = false
		end
	elseif event.name == "keyreleased" then
		local key = event.args[1]
		if key == "lctrl" or key == "rctrl" then
			self.keyControl = true
		end
	elseif event.name == "search" then
		if event.text == "" then
			self.needSearch = false
		else
			self.needSearch = true
		end
		
		local focusedItem = self.items[self.focusedItemIndex]
		local cacheData = focusedItem and focusedItem.cacheData
		
		self:selectCache()
		
		self:quickScrollToItemIndex(self:getItemIndex(cacheData))
		self:sendState()
	end
	
	return CacheList.receive(self, event)
end

NoteChartSetList.checkCacheData = function(self, cacheData)
	local base = cacheData.path:find(self.basePath, 1, true)
	if not base then return false end
	if not self.needSearch then return true end
	
	local searchTable = SearchLine.searchTable
	
	local list = Cache.chartsAtSet[cacheData.id]
	if not list or not list[1] then
		return
	end
	
	for i = 1, #list do
		local found = SearchManager:check(list[i], searchTable)
		if found == true then
			return true
		end
	end
end

NoteChartSetList.sortItemsFunction = function(a, b)
	return a.cacheData.path < b.cacheData.path
end

NoteChartSetList.getItemName = function(self, cacheData)
	local list = Cache.chartsAtSet[cacheData.id]
	if list and list[1] then
		return list[1].title
	end
	return cacheData.path
end

NoteChartSetList.selectCache = function(self)
	local items = {}
	
	local chartSetList = Cache.chartSetList
	for i = 1, #chartSetList do
		local chartSetData = chartSetList[i]
		if self:checkCacheData(chartSetData) then
			items[#items + 1] = self:getItem(chartSetData)
		end
	end
	
	if self.needItemsSort then
		table.sort(items, self.sortItemsFunction)
	end
	
	return self:setItems(items)
end

return NoteChartSetList
