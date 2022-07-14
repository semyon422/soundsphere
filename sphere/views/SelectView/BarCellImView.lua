local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")

return function(w, h, align, name, value)
	local r, g, b, a = love.graphics.getColor()

	local limit = 2 * w
	local x = 0
	if align == "right" then
		x = -w
	elseif align == "center" then
		limit = w
	end

	love.graphics.setFont(spherefonts.get("Noto Sans", 16))
	baseline_print(name, x, 19, limit, 1, align)

	local bh = 19
	love.graphics.setColor(r, g, b, a * 0.25)
	love.graphics.rectangle("fill", 0, 26, w, bh, bh / 2, bh / 2)

	if value ~= 0 then
		love.graphics.setColor(r, g, b, a * 0.75)
		love.graphics.rectangle("fill", 0, 26, (w - bh) * value + bh, bh, bh / 2, bh / 2)
	end
	love.graphics.setColor(r, g, b, a)

	just.next(w, h)
end
