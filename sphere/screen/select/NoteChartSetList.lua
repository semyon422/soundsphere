local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Observable		= require("aqua.util.Observable")
local Cache				= require("sphere.database.Cache")
local SearchManager		= require("sphere.database.SearchManager")
local CacheList			= require("sphere.screen.select.CacheList")
local PreviewManager	= require("sphere.screen.select.PreviewManager")

local NoteChartSetList = CacheList:new()

NoteChartSetList.x = 0.6
NoteChartSetList.y = 0
NoteChartSetList.w = 0.4
NoteChartSetList.h = 1

NoteChartSetList.sender = NoteChartSetList
NoteChartSetList.searchString = ""

NoteChartSetList.buttonCount = 17
NoteChartSetList.middleOffset = 9
NoteChartSetList.startOffset = 9
NoteChartSetList.endOffset = 9

NoteChartSetList.basePath = "userdata/charts"
NoteChartSetList.keyControl = true
NoteChartSetList.needItemsSort = true
NoteChartSetList.needSearch = false

NoteChartSetList.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
end

NoteChartSetList.send = function(self, event)
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
	end
	
	return CacheList.receive(self, event)
end

NoteChartSetList.checkCacheData = function(self, cacheData)
	local base = cacheData.path:find(self.basePath, 1, true)
	if not base then return false end
	if not self.needSearch then return true end
	
	local list = Cache.chartsAtSet[cacheData.id]
	if not list or not list[1] then
		return
	end
	
	for i = 1, #list do
		local found = SearchManager:check(list[i], self.searchString)
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
