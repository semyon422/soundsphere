local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")

return function(w, h, align, name, value, isMono)
	love.graphics.setColor(1, 1, 1, 1)

	local limit = 2 * w
	local x = 0
	if align == "right" then
		x = -w
	end

	love.graphics.setFont(spherefonts.get("Noto Sans", 16))
	baseline_print(name, x, 19, limit, 1, align)

	if isMono then
		love.graphics.setFont(spherefonts.get("Noto Sans Mono", 24))
	else
		love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	end
	baseline_print(value or 0, x, 45, limit, 1, align)

	just.nextline(w, h)
end
