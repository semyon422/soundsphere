local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Rectangle			= require("aqua.graphics.Rectangle")

local SelectFrame = Rectangle:new({
	cs = CoordinateManager:getCS(0, 0, 0, 0, "all"),
	x = 0.588,
	y = 8/17,
	w = 0.5,
	h = 1/17,
	ry = 1/34,
	mode = "line",
	color = {255, 221, 85, 255},
	lineStyle = "smooth",
	lineWidth = 2
})

return SelectFrame
