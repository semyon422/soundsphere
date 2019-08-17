local aquafonts			= require("aqua.assets.fonts")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local spherefonts		= require("sphere.assets.fonts")
local BrowserList		= require("sphere.screen.browser.BrowserList")
local Footer			= require("sphere.screen.select.Footer")
local Header			= require("sphere.screen.select.Header")
local MetaDataTable		= require("sphere.screen.select.MetaDataTable")
local ModifierDisplay	= require("sphere.screen.select.ModifierDisplay")
local NoteChartList		= require("sphere.screen.select.NoteChartList")
local NoteChartSetList	= require("sphere.screen.select.NoteChartSetList")
local SearchLine		= require("sphere.screen.select.SearchLine")
local SelectFrame		= require("sphere.screen.select.SelectFrame")

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
