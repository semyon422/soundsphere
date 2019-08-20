local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Rectangle			= require("aqua.graphics.Rectangle")

local SelectFrame = {}

SelectFrame.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
	
	self.frame = Rectangle:new({
		cs = self.cs,
		x = -0.1,
		y = 8/17,
		w = 1.2,
		h = 1/17,
		ry = 0,
		mode = "line",
		color = {255, 221, 85, 255},
		lineStyle = "smooth",
		lineWidth = 2
	})
end

SelectFrame.reload = function(self)
	self.frame:reload()
end

SelectFrame.draw = function(self)
	self.frame:draw()
end

return SelectFrame
