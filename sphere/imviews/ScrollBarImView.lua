local just = require("just")
local map = require("aqua.math").map

local isOver = function(w, h)
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	return 0 <= x and x <= w and 0 <= y and y <= h
end

local getPosition = function(w, h, _h)
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local value = map(y, _h / 2, h - _h / 2, 0, 1)
	return math.min(math.max(value, 0), 1)
end

local size = 1
return function(id, value, w, h, overlap)
	if overlap == 0 then
		return 0
	end
	local _h = w + (h - w) * h / (overlap + h)

	local over = isOver(w, h)
	local pos = getPosition(w, h, _h)

	local new_value, active, hovered = just.slider(id, over, pos, value)

	love.graphics.setColor(1, 1, 1, 0.2)
	if hovered then
		local alpha = active and 0.4 or 0.3
		love.graphics.setColor(1, 1, 1, alpha)
	end
	love.graphics.rectangle("fill", 0, 0, w, h, w / 2, w / 2)

	love.graphics.setColor(1, 1, 1, 1)

	local x = w * (1 - size) / 2
	love.graphics.rectangle(
		"fill",
		x,
		x + (h - _h) * value,
		w - x * 2,
		_h - x * 2,
		(w - x * 2) / 2,
		(w - x * 2) / 2
	)
	just.next(w, h)

	return new_value or value
end
