local just = require("just")
local just_print = require("just.print")

local function _print(text, x, y, w, h)
	just_print(text, x, y, w, h, "center", "center")
end

local function print_values(w, h, ratio, name, value)
	local font = love.graphics.getFont()
	local nameWidth = font:getWidth(name) + 20
	local valueWidth = font:getWidth(value) + 20
	local fullWidth = nameWidth + valueWidth

	if fullWidth > w then
		_print(name, 0, 0, nameWidth, h)
		_print(value, nameWidth, 0, valueWidth, h)
	elseif fullWidth > w * (1 - ratio) or nameWidth <= w * ratio then
		_print(name, 0, 0, nameWidth, h)
		local offset = valueWidth > w * (1 - ratio) and valueWidth or 0
		_print(value, math.max(nameWidth, w * ratio - offset), 0, valueWidth, h)
	else
		_print(name, w * ratio, 0, nameWidth, h)
		_print(value, nameWidth + w * ratio, 0, valueWidth, h)
	end
end

local shadow = 2
return function(w, h, ratio, name, value)
	love.graphics.setColor(1, 1, 1, 0.2)
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setColor(0.9, 0.7, 0, 1)
	love.graphics.rectangle("fill", 0, 0, w * ratio, h)

	love.graphics.translate(shadow, shadow)
	love.graphics.setColor(0, 0, 0, 1)
	print_values(w, h, ratio, name, value)

	love.graphics.translate(-shadow, -shadow)
	love.graphics.setColor(1, 1, 1, 1)
	print_values(w, h, ratio, name, value)

	just.next(w, h)
end
