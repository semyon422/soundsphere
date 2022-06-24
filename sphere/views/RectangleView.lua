
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")

local RectangleView = Class:new()

RectangleView.draw = function(self)
	for _, rectangle in ipairs(self.rectangles) do
		self:drawRectangle(rectangle)
	end
end

RectangleView.drawRectangle = function(self, rectangle)
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
