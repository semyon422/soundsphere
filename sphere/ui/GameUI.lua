local NoteChartSetList = require("sphere.ui.NoteChartSetList")
local NoteChartList = require("sphere.ui.NoteChartList")
local ModifierList = require("sphere.ui.ModifierList")
local MetaDataTable = require("sphere.ui.MetaDataTable")
local ModifierDisplay = require("sphere.ui.ModifierDisplay")
local SearchLine = require("sphere.ui.SearchLine")
local BrowserList = require("sphere.ui.BrowserList")
local TableMenu = require("sphere.ui.TableMenu")
local SelectFrame = require("sphere.ui.SelectFrame")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local GameUI = {}

GameUI.init = function(self)
	self.csh = CoordinateManager:getCS(0, 0, 0, 0, "h")
	self.csall = CoordinateManager:getCS(0, 0, 0, 0, "all")
	
	self.table10x17all = TableMenu:new({
		x = 0, y = 0, w = 1, h = 1,
		cols = 10, rows = 17,
		cs = self.csall
	})
	self.table17x17h = TableMenu:new({
		x = 0, y = 0, w = 1, h = 1,
		cols = 17, rows = 17,
		cs = self.csh
	})
	
	self.table10x17all:apply(NoteChartSetList, 7, 1, 10, 17)
	self.table10x17all:apply(NoteChartList, 1, 5, 6, 13)
	self.table10x17all:apply(SearchLine, 1, 1, 6, 1, 0.005)
	self.table10x17all:apply(ModifierDisplay, 1, 17, 6, 17)
	
	self.table10x17all:apply(SelectFrame, 6.88, 9, 11, 9)
	SelectFrame.ry = SelectFrame.h / 2
	
	self.table17x17h:apply(ModifierList, 2, 14, 6, 16)
	self.table17x17h:apply(MetaDataTable, 2, 2, 17, 2)
	self.table17x17h:apply(BrowserList, 2, 1, 40, 17)
end

GameUI.receive = function(self, event)
	if event.name == "resize" then
		self.csh:reload()
		self.csall:reload()
	end
end

return GameUI
