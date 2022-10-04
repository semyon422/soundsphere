local map			= require("math_util").map
local Class			= require("Class")

local SliderView = Class:new()

SliderView.isOver = function(self, w, h)
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	return 0 <= x and x <= w and 0 <= y and y <= h
end

SliderView.getPosition = function(self, w, h)
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local value = map(x, h / 2, w - h / 2, 0, 1)
	return math.min(math.max(value, 0), 1)
end

SliderView.draw = function(self, w, h, value)
	local bh = h / 3

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle(
		"line",
		(h - bh) / 2,
		(h - bh) / 2,
		w - (h - bh),
		bh,
		bh / 2,
		bh / 2
	)

	love.graphics.circle(
		"fill",
		map(value, 0, 1, h / 2, w - h / 2),
		h / 2,
		h / 4
	)
	love.graphics.circle(
		"line",
		map(value, 0, 1, h / 2, w - h / 2),
		h / 2,
		h / 4
	)
end

return SliderView
