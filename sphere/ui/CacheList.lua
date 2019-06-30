local Observable = require("aqua.util.Observable")
local Cache = require("sphere.game.NoteChartManager.Cache")
local BackgroundManager = require("sphere.ui.BackgroundManager")
local PreviewManager = require("sphere.ui.PreviewManager")
local CustomList = require("sphere.ui.CustomList")
local NotificationLine = require("sphere.ui.NotificationLine")

local CacheList = CustomList:new()

CacheList.needItemsSort = false
CacheList.sender = "CacheList"
CacheList.basePath = ""

CacheList.load = function(self)
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
	else
		return cacheData.path
	end
end

CacheList.getBackgroundPath = function(self, itemIndex)
	local cacheData = self.items[itemIndex].cacheData
	
	local directoryPath
	if cacheData.chartSetId then
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

CacheList.getAudioPath = function(self, itemIndex)
	local cacheData = self.items[itemIndex].cacheData
	
	local directoryPath
	if cacheData.chartSetId then
		local directoryPathTable = cacheData.path:split("/")
		directoryPathTable[#directoryPathTable] = nil
		directoryPath = table.concat(directoryPathTable, "/")
	else
		directoryPath = cacheData.path
	end
	
	local audioPath
	if cacheData.audioPath and cacheData.audioPath ~= "" then
		audioPath = cacheData.audioPath
	else
		audioPath = "preview.ogg"
	end
	
	return directoryPath .. "/" .. audioPath, cacheData.previewTime
end

CacheList.updateBackground = function(self)
	if not self.items[self.focusedItemIndex] then return end
	return BackgroundManager:loadDrawableBackground(self:getBackgroundPath(self.focusedItemIndex))
end

CacheList.updateAudio = function(self)
	if not self.items[self.focusedItemIndex] then return end
	return PreviewManager:playAudio(self:getAudioPath(self.focusedItemIndex))
end

CacheList.updateCache = function(self, path, recursive)
	CacheList.lock = true
	return Cache:update(path, recursive, function()
		CacheList.lock = false
		Cache:select()
		return NotificationLine:notify("Cache updated. (" .. path .. ")")
	end)
end

return CacheList
