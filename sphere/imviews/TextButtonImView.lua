local just = require("just")
local just_print = require("just.print")

return function(id, text, w, h, align)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local over = 0 <= mx and mx <= w and 0 <= my and my <= h

	local changed, active, hovered = just.button(id, over)
	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, w, h)
	end
	love.graphics.setColor(1, 1, 1, 1)

	local font = love.graphics.getFont()
	local fh = font:getHeight()
	local p = 0

	align = align or "center"
	if align ~= "center" then
		p = (h - fh) / 2
	end

	just_print(text, p, 0, w - p * 2, h, align, "center")

	just.next(w, h)

	return changed
end
