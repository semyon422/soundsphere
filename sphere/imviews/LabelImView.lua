local just = require("just")
local just_print = require("just.print")

return function(id, text, h, align)
	love.graphics.setColor(1, 1, 1, 1)

	local font = love.graphics.getFont()
	local w = font:getWidth(text)

	just.mouse_over(id, just.is_over(w, h), "mouse")

	just_print(text, 0, 0, w, h, align, "center")

	just.next(w, h)
end
