local aquafonts = require("aqua.assets.fonts")
local CS = require("aqua.graphics.CS")
local Rectangle = require("aqua.graphics.Rectangle")
local Stencil = require("aqua.graphics.Stencil")
local utf8 = require("aqua.utf8")
local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")
local Button = require("aqua.ui.Button")
local leftequal = require("aqua.table").leftequal
local sign = require("aqua.math").sign

local spherefonts = require("sphere.assets.fonts")
local GameplayScreen = require("sphere.screen.GameplayScreen")
local Cache = require("sphere.game.NoteChartManager.Cache")
local BackgroundManager = require("sphere.ui.BackgroundManager")
local NotificationLine = require("sphere.ui.NotificationLine")

local NoteChartSetList = require("sphere.game.NoteChartSetList")
local CustomList = require("sphere.game.CustomList")

local ScreenManager = require("sphere.screen.ScreenManager")

local NoteChartList = NoteChartSetList:new()

NoteChartList.sender = "NoteChartList"

NoteChartList.visualItemIndex = 1
NoteChartList.selectedItemIndex = 1

NoteChartList.x = 0.3
NoteChartList.y = 4 / 17
NoteChartList.w = 0.3
NoteChartList.h = 13 / 17
NoteChartList.buttonCount = 13
NoteChartList.middleOffset = 5
NoteChartList.startOffset = 5
NoteChartList.endOffset = 13

NoteChartList.basePath = "userdata/charts"

NoteChartList.observable = Observable:new()

NoteChartList.selectRequest = "SELECT * FROM `cache` WHERE `container` == 0 and INSTR(`path`, ?) == 1 ORDER BY `noteCount`;"

NoteChartList.send = function(self, event)
	if event.action == "scrollStop" then
		local cacheData = self.items[event.itemIndex].cacheData
		if cacheData then
			self:updateBackground()
		end
	elseif event.action == "buttonInteract" then
		local cacheData = self.items[event.itemIndex].cacheData
		if cacheData and cacheData.container == 0 then
			GameplayScreen.cacheData = cacheData
			ScreenManager:set(GameplayScreen)
		end
	end
	
	CustomList.send(self, event)
end

NoteChartList.receive = function(self, event)
	if event.action == "scrollTarget" then
		local cacheData = event.list.items[event.itemIndex].cacheData
		if cacheData.container == 1 then
			self:setBasePath(cacheData.path)
		end
	end
	
	CustomList.receive(self, event)
end

return NoteChartList
