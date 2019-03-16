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
	end
	
	CacheList.send(self, event)
end

NoteChartSetList.receive = function(self, event)
	CacheList.receive(self, event)
end

NoteChartSetList.selectRequest = "SELECT * FROM `cache` WHERE `container` == 1 and INSTR(`path`, ?) == 1 ORDER BY `path`;"

return NoteChartSetList
