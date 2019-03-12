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
NoteChartList.managerContainer = 1

NoteChartList.observable = Observable:new()

NoteChartList.selectRequest = "SELECT * FROM `cache` WHERE `container` == 0 and INSTR(`path`, ?) == 1 ORDER BY `noteCount`;"


return NoteChartList
