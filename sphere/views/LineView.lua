
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")

local LineView = Class:new()

LineView.draw = function(self)
	for _, line in ipairs(self.lines) do
		self:drawLine(line)
	end
end

LineView.drawLine = function(self, line)
	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(line.color)
	love.graphics.setLineWidth(line.lineWidth)
	love.graphics.setLineStyle(line.lineStyle)
	love.graphics.line(line.x1, line.y1, line.x2, line.y2)
end

return LineView
