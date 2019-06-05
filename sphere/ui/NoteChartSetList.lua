local CS = require("aqua.graphics.CS")
local Observable = require("aqua.util.Observable")
local ScreenManager = require("sphere.screen.ScreenManager")
local GameplayScreen = require("sphere.screen.GameplayScreen")
local CacheList = require("sphere.ui.CacheList")

local NoteChartSetList = CacheList:new()

NoteChartSetList.sender = "NoteChartSetList"

NoteChartSetList.x = 0.6
NoteChartSetList.y = 0
NoteChartSetList.w = 1 - NoteChartSetList.x
NoteChartSetList.h = 1
NoteChartSetList.buttonCount = 17
NoteChartSetList.middleOffset = 9
NoteChartSetList.startOffset = 9
NoteChartSetList.endOffset = 9

NoteChartSetList.observable = Observable:new()

NoteChartSetList.basePath = "userdata/charts"
NoteChartSetList.keyControl = true

NoteChartSetList.cs = CS:new({
	bx = 0,
	by = 0,
	rx = 0,
	ry = 0,
	binding = "all",
	baseOne = 768
})

NoteChartSetList.send = function(self, event)
	if event.action == "scrollStop" then
		self.NoteChartList:updateBackground()
		self.NoteChartList:updateAudio()
	elseif event.action == "buttonInteract" then
		local cacheData = self.items[event.itemIndex].cacheData
		if event.button == 2 then
			self:updateCache(cacheData.path)
		end
	elseif event.action == "return" then
		local cacheData = self.NoteChartList.items[self.NoteChartList.focusedItemIndex].cacheData
		if cacheData then
			GameplayScreen.cacheData = cacheData
			ScreenManager:set(GameplayScreen)
		end
	end
	
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

NoteChartSetList.selectRequest = [[
	SELECT * FROM `cache`
	WHERE `container` == 1 AND INSTR(`path`, ? || "/") == 1
	ORDER BY `path`;
]]

return NoteChartSetList
