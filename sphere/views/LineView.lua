
local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local LineView = Class:new()

LineView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

LineView.draw = function(self)
	local config = self.config

	for _, line in ipairs(config.lines) do
		self:drawLine(line)
	end
end

LineView.drawLine = function(self, line)
	local cs = self.cs
	local screen = self.config.screen

	love.graphics.setColor(line.color)
	love.graphics.setLineWidth(cs:X(line.lineWidth / screen.h))
	love.graphics.setLineStyle(line.lineStyle)
	love.graphics.line(
		cs:X(line.x1 / screen.h, true),
		cs:Y(line.y1 / screen.h, true),
		cs:X(line.x2 / screen.h, true),
		cs:Y(line.y2 / screen.h, true)
	)
end

return LineView
