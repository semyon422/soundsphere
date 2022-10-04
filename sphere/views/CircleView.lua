
local Class = require("Class")
local transform = require("gfx_util").transform

local CircleView = Class:new()

CircleView.draw = function(self)
	for _, circle in ipairs(self.circles) do
		self:drawCircle(circle)
	end
end

CircleView.drawCircle = function(self, circle)
	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(circle.color)
	love.graphics.setLineWidth(circle.lineWidth)
	love.graphics.setLineStyle(circle.lineStyle)
	love.graphics.circle(circle.mode, circle.x, circle.y, circle.r)
end

return CircleView
