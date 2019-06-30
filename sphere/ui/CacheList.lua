local Observable = require("aqua.util.Observable")
local Cache = require("sphere.game.NoteChartManager.Cache")
local CacheDatabase = require("sphere.game.NoteChartManager.CacheDatabase")
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

CacheList.checkCacheData = function(self, cacheData)
	return true
end

CacheList.selectCache = function(self)
	local items = {}
	
	if CacheList.lock then
		return self:setItems(items)
	end
	
	local cacheDatas = Cache.cacheDatas
	for i = 1, #cacheDatas do
		local cacheData = cacheDatas[i]
		if self:checkCacheData(cacheData) then
			items[#items + 1] = self:getItem(cacheData)
		end
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

CacheList.getAudioPath = function(self, itemIndex)
	local cacheData = self.items[itemIndex].cacheData
	
	local directoryPath
	if cacheData.container == 0 then
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
	if CacheList.lock then return end
	if not self.items[self.focusedItemIndex] then return end
	return BackgroundManager:loadDrawableBackground(self:getBackgroundPath(self.focusedItemIndex))
end

CacheList.updateAudio = function(self)
	if CacheList.lock then return end
	if not self.items[self.focusedItemIndex] then return end
	return PreviewManager:playAudio(self:getAudioPath(self.focusedItemIndex))
end

CacheList.updateCache = function(self, path, recursive)
	CacheList.lock = true
	return CacheDatabase:update(path, recursive, function()
		CacheList.lock = false
		Cache:select()
		return NotificationLine:notify("Cache updated. (" .. path .. ")")
	end)
end

return CacheList
