local frame_print = require("aqua.graphics.frame_print")
local just = require("just")

return function(id, text, w, h)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local over = 0 <= mx and mx <= w and 0 <= my and my <= h

	local changed, active, hovered = just.button_behavior(id, over)
	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, w, h)
	end
	love.graphics.setColor(1, 1, 1, 1)

	frame_print(text, 0, 0, w, h, 1, "center", "center")

	just.next(w, h)

	return changed
end
