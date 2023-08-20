
local class = require("class")
local transform = require("gfx_util").transform

---@class sphere.RectangleView
---@operator call: sphere.RectangleView
local RectangleView = class()

function RectangleView:draw()
	for _, rectangle in ipairs(self.rectangles) do
		self:drawRectangle(rectangle)
	end
end

---@param rectangle table
function RectangleView:drawRectangle(rectangle)
	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(rectangle.color)
	love.graphics.setLineWidth(rectangle.lineWidth)
	love.graphics.setLineStyle(rectangle.lineStyle)
	love.graphics.rectangle(
		rectangle.mode,
		rectangle.x,
		rectangle.y,
		rectangle.w,
		rectangle.h,
		rectangle.rx,
		rectangle.ry
	)
end

return RectangleView
