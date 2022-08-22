local just = require("just")
local just_print = require("just.print")
local map = require("aqua.math").map

local isOver = function(w, h)
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	return 0 <= x and x <= w and 0 <= y and y <= h
end

local getPosition = function(w, h)
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local value = map(x, h / 2, w - h / 2, 0, 1)
	return math.min(math.max(value, 0), 1)
end

return function(id, value, w, h)
	local over = isOver(w, h)
	local pos = getPosition(w, h)

	local new_value, active, hovered = just.slider(id, over, pos, value)

	local bh = h * 0.75

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
	just.next(w, h)

	return new_value
end
