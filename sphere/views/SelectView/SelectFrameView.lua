
local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local SelectFrameView = Class:new()

SelectFrameView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

SelectFrameView.draw = function(self)
	local config = self.config

	for _, rectangle in ipairs(config.rectangles) do
		self:drawRectangle(rectangle)
	end
	for _, line in ipairs(config.lines) do
		self:drawLine(line)
	end
end

SelectFrameView.drawRectangle = function(self, rectangle)
	local cs = self.cs
	local screen = self.config.screen

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineWidth(cs:X(rectangle.lineWidth / screen.h))
	love.graphics.setLineStyle(rectangle.lineStyle)
	love.graphics.rectangle(
		rectangle.mode,
		cs:X(rectangle.x / screen.h, true),
		cs:Y(rectangle.y / screen.h, true),
		cs:X(rectangle.w / screen.h),
		cs:Y(rectangle.h / screen.h),
		cs:X(rectangle.rx / screen.h),
		cs:X(rectangle.ry / screen.h)
	)
end

SelectFrameView.drawLine = function(self, line)
	local cs = self.cs
	local screen = self.config.screen

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineWidth(cs:X(line.lineWidth / screen.h))
	love.graphics.setLineStyle(line.lineStyle)
	love.graphics.line(
		cs:X(line.x1 / screen.h, true),
		cs:Y(line.y1 / screen.h, true),
		cs:X(line.x2 / screen.h, true),
		cs:Y(line.y2 / screen.h, true)
	)
end

return SelectFrameView
