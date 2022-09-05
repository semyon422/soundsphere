local just = require("just")

return function(id, v, size, scale)
	scale = scale or 0.75
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local over = 0 <= mx and mx <= size and 0 <= my and my <= size

	local changed, active, hovered = just.button(id, over)

	love.graphics.setColor(1, 1, 1, 0.2)
	if hovered then
		local alpha = active and 0.4 or 0.3
		love.graphics.setColor(1, 1, 1, alpha)
	end
	love.graphics.circle("fill", size / 2, size / 2, size / 2 * scale)

	love.graphics.setColor(1, 1, 1, 1)
	if v then
		love.graphics.circle("fill", size / 2, size / 2, size / 4 * scale / 0.75, 64)
		love.graphics.circle("line", size / 2, size / 2, size / 4 * scale / 0.75, 64)
	end

	just.next(size, size)

	return changed
end
