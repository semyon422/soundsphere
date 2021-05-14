
local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local CircleView = Class:new()

CircleView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

CircleView.draw = function(self)
	local config = self.config

	for _, circle in ipairs(config.circles) do
		self:drawCircle(circle)
	end
end

CircleView.drawCircle = function(self, circle)
	local cs = self.cs
	local screen = self.config.screen

	love.graphics.setColor(circle.color)
	love.graphics.setLineWidth(cs:X(circle.lineWidth / screen.h))
	love.graphics.setLineStyle(circle.lineStyle)
	love.graphics.circle(
		circle.mode,
		cs:X(circle.x / screen.h, true),
		cs:Y(circle.y / screen.h, true),
		cs:X(circle.r / screen.h)
	)
end

return CircleView
