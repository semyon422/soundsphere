
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")

local RectangleView = Class:new()

RectangleView.draw = function(self)
	local config = self.config

	for _, rectangle in ipairs(config.rectangles) do
		self:drawRectangle(rectangle)
	end
end

RectangleView.drawRectangle = function(self, rectangle)
	local config = self.config

	love.graphics.replaceTransform(transform(config.transform))

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
