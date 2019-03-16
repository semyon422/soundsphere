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

local CacheList = require("sphere.game.CacheList")

local ScreenManager = require("sphere.screen.ScreenManager")
local NoteChartSetList = require("sphere.game.NoteChartSetList")

local BrowserList = CacheList:new()

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

BrowserList.send = function(self, event)
	if event.action == "buttonInteract" then
		local cacheData = self.items[event.itemIndex].cacheData
		if cacheData then
			NoteChartSetList:setBasePath(cacheData.path)
		end
	end
	
	CacheList.send(self, event)
end

BrowserList.receive = function(self, event)
	CacheList.receive(self, event)
end

BrowserList.sortItemsFunction = function(a, b)
	return a.cacheData.path < b.cacheData.path
end

BrowserList.selectRequest = "SELECT * FROM `cache` WHERE `container` == 2 and INSTR(`path`, ?) == 1 ORDER BY `path`;"

BrowserList.getItemName = function(self, cacheData)
	local directoryPath, folderName = cacheData.path:match("^(.+)/(.-)$")
	return (" "):rep(#directoryPath) .. folderName
end

return BrowserList
