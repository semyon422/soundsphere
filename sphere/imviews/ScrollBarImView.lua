local just = require("just")

local dragPosition
local getPosition = function(h, _h)
	if not dragPosition then
		return 0
	end
	local _, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	-- local value = map(y, _h * dragPosition, h - _h * (1 - dragPosition), 0, 1)
	local value = (y - _h * dragPosition) / (h - _h)
	return math.min(math.max(value, 0), 1)
end

local size = 0.5
return function(id, value, w, h, overlap)
	if overlap <= 0 then
		return
	end
	local _h = w + (h - w) / (overlap + 1)

	local over = just.is_over(w, h)
	local pos = getPosition(h, _h)

	local new_value, active, hovered = just.slider(id, over, pos, value)
	if just.active_id == id and not dragPosition then
		new_value = nil
		local _, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
		dragPosition = (y - (h - _h) * value) / _h
		if dragPosition < 0 or dragPosition > 1 then
			dragPosition = 0.5
		end
	elseif not just.active_id and dragPosition then
		dragPosition = nil
	end

	love.graphics.setColor(1, 1, 1, 0.2)
	if hovered then
		local alpha = active and 0.4 or 0.3
		love.graphics.setColor(1, 1, 1, alpha)
	end
	love.graphics.rectangle("fill", 0, 0, w, h)

	love.graphics.setColor(1, 1, 1, 0.8)

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

	return new_value
end
