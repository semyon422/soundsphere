local Observable = require("aqua.util.Observable")
local Cache = require("sphere.game.NoteChartManager.Cache")
local BackgroundManager = require("sphere.ui.BackgroundManager")
local CustomList = require("sphere.ui.CustomList")
local NotificationLine = require("sphere.ui.NotificationLine")

local CacheList = CustomList:new()

CacheList.needItemsSort = false
CacheList.sender = "CacheList"
CacheList.basePath = ""

CacheList.load = function(self)
	self.db = Cache.db
	
	self.selectStatement = self.db:prepare(self.selectRequest)
	self:selectCache()
	
	return CustomList.load(self)
end

CacheList.setBasePath = function(self, path)
	self.basePath = path
	self:selectCache()
	self:unloadButtons()
	self:calculateButtons()
end

CacheList.sortItemsFunction = function(a, b)
	return a.name < b.name
end
local colnames = {
	"path", "hash", "container", "title", "artist", "source", "tags", "name", "level", "creator", "audioPath", "stagePath", "previewTime", "noteCount", "length", "bpm", "inputMode"
}
CacheList.selectRequest = "SELECT * FROM `cache` WHERE INSTR(`path`, ?) == 1 ORDER BY `path`;"
CacheList.selectCache = function(self)
	local items = {}
	
	if CacheList.lock then
		return self:setItems(items)
	end
	
	local stmt = self.selectStatement:reset():bind(self.basePath)
	local row = stmt:step()
	while row do
		local cacheData = {}
		for i = 1, #colnames do
			cacheData[colnames[i]] = row[i]
		end
		items[#items + 1] = self:getItem(cacheData)
		row = stmt:step()
	end
	if self.needItemsSort then
		table.sort(items, self.sortItemsFunction)
	end
	
	return self:setItems(items)
end

CacheList.getItem = function(self, cacheData)
	local item = {}
	
	item.cacheData = cacheData
	item.name = self:getItemName(cacheData)
	
	return item
end

CacheList.getItemName = function(self, cacheData)
	if cacheData.name and cacheData.name ~= "" then
		return cacheData.name
	elseif cacheData.title and cacheData.title ~= "" then
		return cacheData.title
	elseif cacheData.container == 0 then
		return "."
	else
		return cacheData.path
	end
end

CacheList.getBackgroundPath = function(self, itemIndex)
	local cacheData = self.items[itemIndex].cacheData
	
	local directoryPath
	if cacheData.container == 0 then
		local directoryPathTable = cacheData.path:split("/")
		directoryPathTable[#directoryPathTable] = nil
		directoryPath = table.concat(directoryPathTable, "/")
	else
		directoryPath = cacheData.path
	end
	
	local stagePath
	if cacheData.stagePath and cacheData.stagePath ~= "" then
		stagePath = cacheData.stagePath
	else
		stagePath = "background.jpg"
	end
	
	return directoryPath .. "/" .. stagePath
end

CacheList.updateBackground = function(self)
	if CacheList.lock then return end
	if not self.items[self.focusedItemIndex] then return end
	return BackgroundManager:loadDrawableBackground(self:getBackgroundPath(self.focusedItemIndex))
end

CacheList.updateCache = function(self, path)
	CacheList.lock = true
	return Cache:update(path, recursive, function()
		CacheList.lock = false
		return NotificationLine:notify("Cache updated. (" .. path .. ")")
	end)
end

return CacheList
