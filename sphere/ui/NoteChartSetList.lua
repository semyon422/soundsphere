local CS = require("aqua.graphics.CS")
local Observable = require("aqua.util.Observable")
local ScreenManager = require("sphere.screen.ScreenManager")
local GameplayScreen = require("sphere.screen.GameplayScreen")
local CacheList = require("sphere.ui.CacheList")
local PreviewManager = require("sphere.ui.PreviewManager")
local SearchLine = require("sphere.ui.SearchLine")
local Cache = require("sphere.game.NoteChartManager.Cache")

local NoteChartSetList = CacheList:new()

SearchLine.observable:add(NoteChartSetList)

NoteChartSetList.sender = "NoteChartSetList"

NoteChartSetList.x = 0.6
NoteChartSetList.y = 0
NoteChartSetList.w = 1 - NoteChartSetList.x
NoteChartSetList.h = 1
NoteChartSetList.buttonCount = 17
NoteChartSetList.middleOffset = 9
NoteChartSetList.startOffset = 9
NoteChartSetList.endOffset = 9

NoteChartSetList.observable = Observable:new()

NoteChartSetList.basePath = "userdata/charts"
NoteChartSetList.keyControl = true
NoteChartSetList.needItemsSort = true
NoteChartSetList.needSearch = false
NoteChartSetList.searchString = ""

NoteChartSetList.cs = CS:new({
	bx = 0,
	by = 0,
	rx = 0,
	ry = 0,
	binding = "all",
	baseOne = 768
})

NoteChartSetList.send = function(self, event)
	if event.action == "scrollStop" then
		self.NoteChartList:updateBackground()
		self.NoteChartList:updateAudio()
	elseif event.action == "buttonInteract" then
		local cacheData = self.items[event.itemIndex].cacheData
		if event.button == 2 then
			local recursive = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
			self:updateCache(cacheData.path, recursive)
		end
	elseif event.action == "return" then
		local cacheData = self.NoteChartList.items[self.NoteChartList.focusedItemIndex].cacheData
		if cacheData then
			PreviewManager:stop()
			GameplayScreen.cacheData = cacheData
			ScreenManager:set(GameplayScreen)
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
			self.searchString = ""
		else
			self.needSearch = true
			self.searchString = event.text
		end
		self:selectCache()
		self:unloadButtons()
		self:calculateButtons()
	end
	
	return CacheList.receive(self, event)
end

NoteChartSetList.checkCacheData = function(self, cacheData)
	local base = cacheData.path:find(self.basePath, 1, true)
	if not base then return false end
	if not self.needSearch then return true end
	
	local searchString = self.searchString:lower()
	
	local list = Cache.chartsAtSet[cacheData.id]
	if not list or not list[1] then
		return
	end
	
	for i = 1, #list do
		local chart = list[i]
		if
			chart.path and chart.path:lower():find(searchString, 1, true) or
			chart.artist and chart.artist:lower():find(searchString, 1, true) or
			chart.title and chart.title:lower():find(searchString, 1, true) or
			chart.name and chart.name:lower():find(searchString, 1, true) or
			chart.source and chart.source:lower():find(searchString, 1, true) or
			chart.tags and chart.tags:lower():find(searchString, 1, true) or
			chart.creator and chart.creator:lower():find(searchString, 1, true) or
			chart.inputMode and chart.inputMode:lower():find(searchString, 1, true)
		then
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
