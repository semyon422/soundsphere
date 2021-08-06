
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")

local LineView = Class:new()

LineView.draw = function(self)
	local config = self.config

	for _, line in ipairs(config.lines) do
		self:drawLine(line)
	end
end

LineView.drawLine = function(self, line)
	local config = self.config

	love.graphics.replaceTransform(transform(config.transform))

	love.graphics.setColor(line.color)
	love.graphics.setLineWidth(line.lineWidth)
	love.graphics.setLineStyle(line.lineStyle)
	love.graphics.line(line.x1, line.y1, line.x2, line.y2)
end

return LineView
