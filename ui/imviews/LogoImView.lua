local just = require("just")
local logo = require("sphere.views.logo")

return function(id, size, scale)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local over = 0 <= mx and mx <= size and 0 <= my and my <= size

	local changed, active, hovered = just.button(id, over)
	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, size, size)
	end
	love.graphics.setColor(1, 1, 1, 1)

	local x = size * (1 - scale) / 2
	local w = size * scale

	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(1)
	logo.draw("line", x, x, w)
	logo.draw("fill", x, x, w)

	just.next(size, size)

	return changed
end
