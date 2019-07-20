local Rectangle = require("aqua.graphics.Rectangle")

local SelectFrame = Rectangle:new({
	mode = "line",
	color = {255, 255, 255, 255},
	lineStyle = "smooth",
	lineWidth = 2
})

return SelectFrame
