local NoteChartSetList	= require("sphere.ui.NoteChartSetList")
local NoteChartList		= require("sphere.ui.NoteChartList")
local ModifierList		= require("sphere.ui.ModifierList")
local MetaDataTable		= require("sphere.ui.MetaDataTable")
local ModifierDisplay	= require("sphere.ui.ModifierDisplay")
local SearchLine		= require("sphere.ui.SearchLine")
local BrowserList		= require("sphere.ui.BrowserList")
local SelectFrame		= require("sphere.ui.SelectFrame")
local SearchLine		= require("sphere.ui.SearchLine")
local Header			= require("sphere.ui.Header")
local Footer			= require("sphere.ui.Footer")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local set = function(object1, object2)
	for key, value in pairs(object2) do
		object1[key] = value
	end
end

local cs = {
	all	= CoordinateManager:getCS(0, 0, 0, 0, "all"),
	h	= CoordinateManager:getCS(0, 0, 0, 0, "h"),
	h06	= CoordinateManager:getCS(0.6, 0, 0, 0, "h")
}

local padding = 0.005
set(SearchLine, {
	cs1 = cs.h, x1 = padding, y1 = padding,
	cs2 = cs.h06, x2 = -padding, y2 = 1/17 - padding,
	ry = (1/17 - 2 * padding) / 2,
	font = aquafonts.getFont(spherefonts.NotoSansRegular, 20)
})

set(MetaDataTable, {
	cs1 = cs.h, x1 = 1/17, y1 = 1/17,
	cs2 = cs.h06, x2 = 0, y2 = 3/17
})

set(Header, {
	cs = cs.all,
	topx = 0, topy = 0, topw = 1, toph = 1/17,
	bottomx = 0, bottomy = 1/17, bottomw = 1, bottomh = 2/17,
	topColor = {0, 0, 0, 127},
	bottomColor = {0, 0, 0, 191}
})

set(Footer, {
	cs = cs.all,
	x = 0, y = 16/17, w = 1, h = 1/17,
	color = {0, 0, 0, 127}
})

set(NoteChartSetList, {
	cs = cs.all, x = 0.6, y = 0, w = 0.4, h = 1
})

set(NoteChartList, {
	cs = cs.all, x = 0, y = 4/17, w = 0.6, h = 9/17
})

set(ModifierDisplay, {
	cs = cs.all, x = 0, y = 16/17, w = 0.6, h = 1/17
})

set(SelectFrame, {
	cs = cs.all, x = 0.588, y = 8/17, w = 0.5, h = 1/17, ry = 1/34
})

set(ModifierList, {
	cs = cs.h, x = 1/17, y = 13/17, w = 6/17, h = 3/17
})

set(BrowserList, {
	cs = cs.h, x = 1/17, y = 0, w = 10, h = 1
})
