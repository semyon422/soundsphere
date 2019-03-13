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

local BrowserList = CustomList:new()

BrowserList.sender = "BrowserList"
BrowserList.needFocusToInteract = false

BrowserList.x = 0.1
BrowserList.y = 0
BrowserList.w = 1 - 2 * BrowserList.x
BrowserList.h = 1
BrowserList.buttonCount = 21
BrowserList.middleOffset = 11
BrowserList.startOffset = 11
BrowserList.endOffset = 11

BrowserList.observable = Observable:new()

BrowserList.basePath = "userdata/charts"

BrowserList.cs = CS:new({
	bx = 0,
	by = 0,
	rx = 0,
	ry = 0,
	binding = "all",
	baseOne = 768
})

BrowserList.load = function(self)
	self.db = Cache.db
	
	self.selectStatement = self.db:prepare(self.selectRequest)
	self:selectCache()
	
	self.font = aquafonts.getFont(spherefonts.NotoMonoRegular, 20)
	
	CustomList.load(self)
end

BrowserList.send = function(self, event)
	CustomList.send(self, event)
end

BrowserList.receive = function(self, event)
	CustomList.receive(self, event)
end

local sortItemsFunction = function(a, b)
	return a.cacheData.path < b.cacheData.path
end
local colnames = {
	"path", "hash", "container", "title", "artist", "source", "tags", "name", "level", "creator", "audioPath", "stagePath", "previewTime", "noteCount", "length", "bpm", "inputMode"
}
BrowserList.selectRequest = "SELECT * FROM `cache` WHERE `container` == 2 and INSTR(`path`, ?) == 1 ORDER BY `path`;"
BrowserList.selectCache = function(self)
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

BrowserList.getItem = function(self, cacheData)
	local item = {}
	
	item.cacheData = cacheData
	item.name = self:getItemName(cacheData)
	
	return item
end

BrowserList.getItemName = function(self, cacheData)
	local directoryPath, folderName = cacheData.path:match("^(.+)/(.-)$")
	return (" "):rep(#directoryPath) .. folderName
end

return BrowserList
