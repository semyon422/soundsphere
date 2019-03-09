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
local Cache = require("sphere.game.NoteChartManager.Cache")
local BackgroundManager = require("sphere.ui.BackgroundManager")
local NotificationLine = require("sphere.ui.NotificationLine")

local NoteChartSetList = require("sphere.game.NoteChartSetList")

local ScreenManager = require("sphere.screen.ScreenManager")

local NoteChartList = {}

NoteChartList.visualItemIndex = 1
NoteChartList.selectedItemIndex = 1

NoteChartList.x = 0.3
NoteChartList.y = (1 - 8 / 17) / 2
NoteChartList.w = 0.3
NoteChartList.h = 8 / 17
NoteChartList.rectangleColor = {255, 255, 255, 0}
NoteChartList.textColor = {255, 255, 255, 255}
NoteChartList.selectedRectangleColor = {255, 255, 255, 0}
NoteChartList.mode = "fill"
NoteChartList.limit = 2
NoteChartList.textAlign = {
	x = "left", y = "center"
}
NoteChartList.buttonCount = 8

NoteChartList.basePath = "userdata/charts"
NoteChartList.currentCacheData = {path = "userdata/charts"}

NoteChartList.managerContainer = 1

NoteChartList.cs = NoteChartSetList.cs

NoteChartList.observable = Observable:new()
NoteChartList.font = NoteChartSetList.font
NoteChartList.postLoad = NoteChartSetList.postLoad

NoteChartList.selectRequest = "SELECT * FROM `cache` WHERE `container` == 0 and INSTR(`path`, '%s') == 1 ORDER BY `noteCount`;"

NoteChartList.load = NoteChartSetList.load
NoteChartList.draw = NoteChartSetList.draw
NoteChartList.setBasePath = NoteChartSetList.setBasePath
NoteChartList.selectCache = NoteChartSetList.selectCache
NoteChartList.updateCache = NoteChartSetList.updateCache
NoteChartList.updateCurrentCacheData = NoteChartSetList.updateCurrentCacheData
NoteChartList.updateBackground = NoteChartSetList.updateBackground
NoteChartList.updateItems = NoteChartSetList.updateItems
NoteChartList.getItemName = NoteChartSetList.getItemName
NoteChartList.addItem = NoteChartSetList.addItem
NoteChartList.unload = NoteChartSetList.unload
NoteChartList.getMiddleOffset = NoteChartSetList.getMiddleOffset
NoteChartList.update = NoteChartSetList.update
NoteChartList.send = NoteChartSetList.send
NoteChartList.receive = NoteChartSetList.receive
NoteChartList.getStartItemIndex = NoteChartSetList.getStartItemIndex
NoteChartList.getEndItemIndex = NoteChartSetList.getEndItemIndex
NoteChartList.loadOverlay = NoteChartSetList.loadOverlay
NoteChartList.scrollToItemIndex = NoteChartSetList.scrollToItemIndex
NoteChartList.scrollBy = NoteChartSetList.scrollBy
NoteChartList.calculateButtons = NoteChartSetList.calculateButtons
NoteChartList.addButton = NoteChartSetList.addButton
NoteChartList.unloadButtons = NoteChartSetList.unloadButtons
NoteChartList.Button = NoteChartSetList.Button

return NoteChartList
