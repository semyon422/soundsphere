
local class = require("class")
local transform = require("gfx_util").transform

---@class sphere.CircleView
---@operator call: sphere.CircleView
local CircleView = class()

function CircleView:draw()
	for _, circle in ipairs(self.circles) do
		self:drawCircle(circle)
	end
end

---@param circle table
function CircleView:drawCircle(circle)
	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(circle.color)
	love.graphics.setLineWidth(circle.lineWidth)
	love.graphics.setLineStyle(circle.lineStyle)
	love.graphics.circle(circle.mode, circle.x, circle.y, circle.r)
end

return CircleView
