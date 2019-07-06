local CS = require("aqua.graphics.CS")
local Observable = require("aqua.util.Observable")
local ScreenManager = require("sphere.screen.ScreenManager")
local GameplayScreen = require("sphere.screen.GameplayScreen")
local CacheList = require("sphere.ui.CacheList")
local PreviewManager = require("sphere.ui.PreviewManager")
local Cache = require("sphere.game.NoteChartManager.Cache")
local SearchLine = require("sphere.ui.SearchLine")

local NoteChartList = CacheList:new()

NoteChartList.sender = "NoteChartList"

NoteChartList.x = 0.3
NoteChartList.y = 4 / 17
NoteChartList.w = 0.3
NoteChartList.h = 9 / 17
NoteChartList.buttonCount = 9
NoteChartList.middleOffset = 5
NoteChartList.startOffset = 5
NoteChartList.endOffset = 5

NoteChartList.basePath = "?"
NoteChartList.chartSetId = 0
NoteChartList.needItemsSort = true

NoteChartList.observable = Observable:new()

NoteChartList.send = function(self, event)
	if event.action == "scrollStop" then
		local cacheData = self.items[event.itemIndex].cacheData
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
			self.chartSetId = item.cacheData.id
			self:selectCache()
			self:unloadButtons()
			self:calculateButtons()
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
	for i = 1, #list do
		if self:checkChartData(list[i], SearchLine.searchTable) then
			items[#items + 1] = self:getItem(list[i])
		end
	end
	
	if self.needItemsSort then
		table.sort(items, self.sortItemsFunction)
	end
	
	return self:setItems(items)
end

NoteChartList.checkChartData = function(self, chart, searchTable)
	local found = true
	for _, searchString in ipairs(searchTable) do
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
			-- skip
		else
			found = false
		end
	end
	return found
end

return NoteChartList
