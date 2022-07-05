local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")

return function(w, h, align, name, value)
	love.graphics.setColor(1, 1, 1, 1)

	local limit = 2 * w
	local x = 0
	if align == "right" then
		x = -w
	end

	love.graphics.setFont(spherefonts.get("Noto Sans", 16))
	baseline_print(name, x, 19, limit, 1, align)

	local bh = 19
	love.graphics.setColor(1, 1, 1, 0.25)
	love.graphics.rectangle("fill", 0, 26, w, bh, bh / 2, bh / 2)

	if value ~= 0 then
		love.graphics.setColor(1, 1, 1, 0.75)
		love.graphics.rectangle("fill", 0, 26, (w - bh) * value + bh, bh, bh / 2, bh / 2)
	end

	just.nextline(w, h)
end
