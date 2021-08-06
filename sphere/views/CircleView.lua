
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")

local CircleView = Class:new()

CircleView.draw = function(self)
	local config = self.config

	for _, circle in ipairs(config.circles) do
		self:drawCircle(circle)
	end
end

CircleView.drawCircle = function(self, circle)
	local config = self.config

	love.graphics.replaceTransform(transform(config.transform))

	love.graphics.setColor(circle.color)
	love.graphics.setLineWidth(circle.lineWidth)
	love.graphics.setLineStyle(circle.lineStyle)
	love.graphics.circle(circle.mode, circle.x, circle.y, circle.r)
end

return CircleView
