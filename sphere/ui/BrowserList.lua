local CS = require("aqua.graphics.CS")
local Observable = require("aqua.util.Observable")
local CacheList = require("sphere.ui.CacheList")
local NoteChartSetList = require("sphere.ui.NoteChartSetList")

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
			self:updateCache(cacheData.path)
		end
	end
	
	return CacheList.send(self, event)
end

BrowserList.getItemName = function(self, cacheData)
	local directoryPath, folderName = cacheData.path:match("^(.+)/(.-)$")
	return (" "):rep(#directoryPath) .. folderName
end

BrowserList.checkCacheData = function(self, cacheData)
	return cacheData.container == 2 and cacheData.path:find(self.basePath)
end

-- BrowserList.selectRequest = [[
	-- SELECT * FROM `cache`
	-- WHERE `container` == 2 AND INSTR(`path`, ?) == 1
	-- ORDER BY `path`;
-- ]]

return BrowserList
