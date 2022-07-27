local just = require("just")

return function(id, v, size, scale)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local over = 0 <= mx and mx <= size and 0 <= my and my <= size

	local changed, active, hovered = just.button(id, over)
	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, size, size)
	end
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.circle("line", size / 2, size / 2, size / 2 * scale)
	if v then
		love.graphics.circle("fill", size / 2, size / 2, size / 2 * scale * 0.6)
		love.graphics.circle("line", size / 2, size / 2, size / 2 * scale * 0.6)
	end

	just.next(size, size)

	return changed
end
