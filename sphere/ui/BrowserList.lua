local CS = require("aqua.graphics.CS")
local Observable = require("aqua.util.Observable")
local CacheList = require("sphere.ui.CacheList")
local NoteChartSetList = require("sphere.ui.NoteChartSetList")
local Cache = require("sphere.game.NoteChartManager.Cache")
local NotificationLine = require("sphere.ui.NotificationLine")

local BrowserList = CacheList:new()

BrowserList.sender = "BrowserList"
BrowserList.needFocusToInteract = false

BrowserList.x = 0.1
BrowserList.y = 0
BrowserList.w = 1 - 2 * BrowserList.x
BrowserList.h = 1
BrowserList.buttonCount = 17
BrowserList.middleOffset = 9
BrowserList.startOffset = 9
BrowserList.endOffset = 9
BrowserList.needItemsSort = true

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
		if event.button == 1 then
			NoteChartSetList:setBasePath(cacheData.path)
		elseif event.button == 2 then
			local recursive = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
			self:updateCache(cacheData.path, recursive)
		end
	end
	
	return CacheList.send(self, event)
end

BrowserList.receive = function(self, event)
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "f5" then
			Cache:select()
			NotificationLine:notify("Cache reloaded from database")
		end
	end
	
	return CacheList.receive(self, event)
end

BrowserList.sortItemsFunction = function(a, b)
	return a.cacheData.path < b.cacheData.path
end

BrowserList.getItemName = function(self, cacheData)
	local directoryPath, folderName = cacheData.path:match("^(.+)/(.-)$")
	return (" "):rep(#directoryPath) .. folderName
end

BrowserList.selectCache = function(self)
	local items = {}
	
	local packList = Cache.packList
	for i = 1, #packList do
		local packData = packList[i]
		if packData.path:find(self.basePath) then
			items[#items + 1] = self:getItem(packData)
		end
	end
	
	if self.needItemsSort then
		table.sort(items, self.sortItemsFunction)
	end
	
	return self:setItems(items)
end

return BrowserList
