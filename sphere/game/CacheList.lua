local aquafonts = require("aqua.assets.fonts")
local CS = require("aqua.graphics.CS")
local Rectangle = require("aqua.graphics.Rectangle")
local Stencil = require("aqua.graphics.Stencil")
local utf8 = require("aqua.utf8")
local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")
local Button = require("aqua.ui.Button")
local sign = require("aqua.math").sign
local belong = require("aqua.math").belong

local spherefonts = require("sphere.assets.fonts")
local Cache = require("sphere.game.NoteChartManager.Cache")
local BackgroundManager = require("sphere.ui.BackgroundManager")
local NotificationLine = require("sphere.ui.NotificationLine")

local CustomList = require("sphere.game.CustomList")

local ScreenManager = require("sphere.screen.ScreenManager")

local CacheList = CustomList:new()

CacheList.needItemsSort = false
CacheList.sender = "CacheList"
CacheList.basePath = ""

CacheList.load = function(self)
	self.db = Cache.db
	
	self.selectStatement = self.db:prepare(self.selectRequest)
	self:selectCache()
	
	CustomList.load(self)
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
	
	self:setItems(items)
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
	BackgroundManager:loadDrawableBackground(self:getBackgroundPath(self.focusedItemIndex))
end

return CacheList
