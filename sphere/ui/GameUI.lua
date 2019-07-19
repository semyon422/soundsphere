local NoteChartSetList = require("sphere.ui.NoteChartSetList")
local NoteChartList = require("sphere.ui.NoteChartList")
local ModifierList = require("sphere.ui.ModifierList")
local MetaDataTable = require("sphere.ui.MetaDataTable")
local ModifierDisplay = require("sphere.ui.ModifierDisplay")
local SearchLine = require("sphere.ui.SearchLine")
local BrowserList = require("sphere.ui.BrowserList")
local TableMenu = require("sphere.ui.TableMenu")
local CS = require("aqua.graphics.CS")

local GameUI = {}

GameUI.init = function(self)
	self.cs = CS:new({
		bx = 0, by = 0, rx = 0, ry = 0,
		binding = "h",
		baseOne = 768
	})
	self.table10x17 = TableMenu:new({
		x = 0, y = 0, w = 1, h = 1,
		cols = 10, rows = 17
	})
	self.table17x17 = TableMenu:new({
		x = 0, y = 0, w = 1, h = 1,
		cols = 17, rows = 17,
		cs = self.cs
	})
	self.table10x17:apply(NoteChartSetList, 7, 1, 10, 17)
	self.table10x17:apply(NoteChartList, 1, 5, 6, 13)
	self.table10x17:apply(SearchLine, 1, 1, 6, 1, 0.005)
	self.table10x17:apply(ModifierDisplay, 1, 17, 6, 17)
	self.table10x17:apply(BrowserList, 2, 1, 9, 17)
	
	self.table17x17:apply(ModifierList, 2, 14, 6, 16)
	self.table17x17:apply(MetaDataTable, 2, 2, 10, 2)
end

GameUI.receive = function(self, event)
	if event.name == "resize" then
		self.cs:reload()
	end
end

return GameUI
