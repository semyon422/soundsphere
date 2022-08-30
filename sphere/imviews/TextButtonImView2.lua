local just = require("just")
local just_print = require("just.print")

local size = 0.75
return function(id, text, w, h)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local over = 0 <= mx and mx <= w and 0 <= my and my <= h

	local changed, active, hovered = just.button(id, over)

	local r = h * size / 2
	local x = h * size * (1 - size) / 2
	love.graphics.setColor(1, 1, 1, 0.2)
	if hovered then
		local alpha = active and 0.4 or 0.3
		love.graphics.setColor(1, 1, 1, alpha)
	end
	love.graphics.rectangle("fill", x, x, w - x * 2, h * size, r)

	love.graphics.setColor(1, 1, 1, 1)
	just_print(text, 0, 0, w, h, "center", "center")

	just.next(w, h)

	return changed
end
