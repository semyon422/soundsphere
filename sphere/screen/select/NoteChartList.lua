local CoordinateManager		= require("aqua.graphics.CoordinateManager")
local Observable			= require("aqua.util.Observable")
local Cache					= require("sphere.database.Cache")
local SearchManager			= require("sphere.database.SearchManager")
local CacheList				= require("sphere.screen.select.CacheList")
local NoteChartListButton	= require("sphere.screen.select.NoteChartListButton")
local PreviewManager		= require("sphere.screen.select.PreviewManager")

local NoteChartList = CacheList:new()

NoteChartList.x = 0
NoteChartList.y = 4/17
NoteChartList.w = 0.6
NoteChartList.h = 9/17

NoteChartList.sender = NoteChartList
NoteChartList.searchString = ""

NoteChartList.buttonCount = 9
NoteChartList.middleOffset = 5
NoteChartList.startOffset = 5
NoteChartList.endOffset = 5

NoteChartList.basePath = "?"
NoteChartList.chartSetId = 0
NoteChartList.needItemsSort = true

NoteChartList.Button = NoteChartListButton

NoteChartList.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
end

NoteChartList.send = function(self, event)
	return CacheList.send(self, event)
end

NoteChartList.receive = function(self, event)
	if event.name == "keypressed" then
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
	local foundList = SearchManager:search(list, self.searchString)
	for i = 1, #foundList do
		items[#items + 1] = self:getItem(foundList[i])
	end
	
	if self.needItemsSort then
		table.sort(items, self.sortItemsFunction)
	end
	
	return self:setItems(items)
end

return NoteChartList
