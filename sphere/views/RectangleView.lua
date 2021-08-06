
local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local RectangleView = Class:new()

RectangleView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

RectangleView.draw = function(self)
	local config = self.config

	for _, rectangle in ipairs(config.rectangles) do
		self:drawRectangle(rectangle)
	end
end

RectangleView.drawRectangle = function(self, rectangle)
	local cs = self.cs
	local screen = self.config.screen

	love.graphics.setColor(rectangle.color)
	love.graphics.setLineWidth(cs:X(rectangle.lineWidth / screen.unit))
	love.graphics.setLineStyle(rectangle.lineStyle)
	love.graphics.rectangle(
		rectangle.mode,
		cs:X(rectangle.x / screen.unit, true),
		cs:Y(rectangle.y / screen.unit, true),
		cs:X(rectangle.w / screen.unit),
		cs:Y(rectangle.h / screen.unit),
		cs:X(rectangle.rx / screen.unit),
		cs:X(rectangle.ry / screen.unit)
	)
end

return RectangleView
