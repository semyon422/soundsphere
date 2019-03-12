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

local NoteChartSetList = CustomList:new()

NoteChartSetList.x = 0.6
NoteChartSetList.y = 0
NoteChartSetList.w = 1 - NoteChartSetList.x
NoteChartSetList.h = 1
NoteChartSetList.buttonCount = 17
NoteChartSetList.middleOffset = 9
NoteChartSetList.startOffset = 9
NoteChartSetList.endOffset = 9

NoteChartSetList.basePath = "userdata/charts"

NoteChartSetList.cs = CS:new({
	bx = 0,
	by = 0,
	rx = 0,
	ry = 0,
	binding = "all",
	baseOne = 768
})

NoteChartSetList.load = function(self)
	self.db = Cache.db
	
	self.selectStatement = self.db:prepare(self.selectRequest)
	self:selectCache()
	
	CustomList.load(self)
	
	self:updateBackground()
end

NoteChartSetList.send = function(self, event)
	if event.action == "scrollStop" then
		self:updateBackground()
	end
	
	CustomList.send(self, event)
end

NoteChartSetList.setBasePath = function(self, path)
	self.basePath = path
	self:selectCache()
	self:unloadButtons()
	self:calculateButtons()
end

local sortItemsFunction = function(a, b)
	return a.name < b.name
end
local colnames = {
	"path", "hash", "container", "title", "artist", "source", "tags", "name", "level", "creator", "audioPath", "stagePath", "previewTime", "noteCount", "length", "bpm", "inputMode"
}
NoteChartSetList.selectRequest = "SELECT * FROM `cache` WHERE `container` == 1 and INSTR(`path`, ?) == 1 ORDER BY `path`;"
NoteChartSetList.selectCache = function(self)
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
	table.sort(items, sortItemsFunction)
	
	self:setItems(items)
end

NoteChartSetList.getItem = function(self, cacheData)
	local item = {}
	
	item.cacheData = cacheData
	item.name = self:getItemName(cacheData)
	
	return item
end

NoteChartSetList.getItemName = function(self, cacheData)
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

NoteChartSetList.getBackgroundPath = function(self, itemIndex)
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

NoteChartSetList.updateBackground = function(self)
	BackgroundManager:loadDrawableBackground(self:getBackgroundPath(self.focusedItemIndex))
end

return NoteChartSetList
