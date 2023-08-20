local map = require("math_util").map
local class = require("class")

---@class sphere.SliderView
---@operator call: sphere.SliderView
local SliderView = class()

---@param w number
---@param h number
---@return boolean
function SliderView:isOver(w, h)
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	return 0 <= x and x <= w and 0 <= y and y <= h
end

---@param w number
---@param h number
---@return number
function SliderView:getPosition(w, h)
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local value = map(x, h / 2, w - h / 2, 0, 1)
	return math.min(math.max(value, 0), 1)
end

---@param w number
---@param h number
---@param value number
function SliderView:draw(w, h, value)
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
