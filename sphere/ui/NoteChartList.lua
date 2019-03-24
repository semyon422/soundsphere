local CS = require("aqua.graphics.CS")
local Observable = require("aqua.util.Observable")

local GameplayScreen = require("sphere.screen.GameplayScreen")

local CacheList = require("sphere.ui.CacheList")
local ScreenManager = require("sphere.screen.ScreenManager")

local NoteChartList = CacheList:new()

NoteChartList.sender = "NoteChartList"

NoteChartList.x = 0.3
NoteChartList.y = 4 / 17
NoteChartList.w = 0.3
NoteChartList.h = 9 / 17
NoteChartList.buttonCount = 9
NoteChartList.middleOffset = 5
NoteChartList.startOffset = 5
NoteChartList.endOffset = 5

NoteChartList.basePath = "userdata/charts"

NoteChartList.observable = Observable:new()

NoteChartList.send = function(self, event)
	if event.action == "scrollStop" then
		local cacheData = self.items[event.itemIndex].cacheData
		if cacheData then
			self:updateBackground()
		end
	elseif event.action == "buttonInteract" then
		local cacheData = self.items[event.itemIndex].cacheData
		if cacheData then
			GameplayScreen.cacheData = cacheData
			ScreenManager:set(GameplayScreen)
		end
	end
	
	CacheList.send(self, event)
end

NoteChartList.receive = function(self, event)
	if event.action == "scrollTarget" then
		local item = event.list.items[event.itemIndex]
		if item and item.cacheData and item.cacheData.container == 1 then
			self:setBasePath(item.cacheData.path)
		end
	end
	
	CacheList.receive(self, event)
end

NoteChartList.selectRequest = [[
	SELECT * FROM `cache`
	WHERE `container` == 0 AND INSTR(`path`, ?) == 1
	ORDER BY
	length(`inputMode`) ASC,
	`inputMode` ASC,
	`noteCount` / `length` ASC;
]]

return NoteChartList
