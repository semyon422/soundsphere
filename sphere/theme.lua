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
	all		= CoordinateManager:getCS(0, 0, 0, 0, "all"),
	h		= CoordinateManager:getCS(0, 0, 0, 0, "h"),
	hright	= CoordinateManager:getCS(1, 0, 0, 0, "h"),
	h06		= CoordinateManager:getCS(0.6, 0, 0, 0, "h")
}

set(SearchLine, {
	cs1 = cs.h06, x1 = (988 - 1080) / 1080, y1 = 84/1080,
	cs2 = cs.hright, x2 = -(1920 - 1892) / 1080, y2 = 129/1080,
	ry = 10/1080,
	font = aquafonts.getFont(spherefonts.NotoSansRegular, 18)
})

set(MetaDataTable, {
	cs1 = cs.h, x1 = 0, y1 = 84/1080,
	cs2 = cs.h06, x2 = (955 - 1080) / 1080, y2 = 218/1080
})

set(Header, {
	cs = cs.all,
	topx = 0, topy = 0, topw = 1, toph = 56/1080,
	bottomx = 0, bottomy = 56/1080, bottomw = 1, bottomh = 134/1080,
	topColor = {0, 0, 0, 127},
	bottomColor = {0, 0, 0, 191}
})

set(NoteChartSetList, {
	cs = cs.all, x = 0.6, y = 0, w = 0.4, h = 1
})

set(NoteChartList, {
	cs = cs.all, x = 0, y = 4/17, w = 0.6, h = 9/17
})

set(SelectFrame, {
	cs = cs.all, x = 0.588, y = 8/17, w = 0.5, h = 1/17, ry = 1/34
})

set(BrowserList, {
	cs = cs.h, x = 1/17, y = 0, w = 10, h = 1
})
