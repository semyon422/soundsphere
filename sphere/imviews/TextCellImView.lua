local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local gfx_util = require("gfx_util")

return function(w, h, align, name, value, isMono)
	local limit = 2 * w
	local x = 0
	if align == "right" then
		x = -w
	elseif align == "center" then
		limit = w
	end

	love.graphics.setFont(spherefonts.get("Noto Sans", 16))
	gfx_util.printBaseline(name, x, 19, limit, 1, align)

	if isMono then
		local font = spherefonts.get("Noto Sans Mono", 24)
		font:setFallbacks(spherefonts.get("Noto Sans", 24))
		love.graphics.setFont(font)
	else
		love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	end
	gfx_util.printBaseline(tostring(value or 0), x, 45, limit, 1, align)

	just.next(w, h)
end
