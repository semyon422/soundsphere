local frame_print = require("aqua.graphics.frame_print")
local just = require("just")

return function(text, h, align)
	love.graphics.setColor(1, 1, 1, 1)

	local font = love.graphics.getFont()
	local w = font:getWidth(text)

	frame_print(text, 0, 0, w, h, 1, align, "center")

	just.nextline(w, h)
end
