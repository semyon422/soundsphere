local just = require("just")
local gfx_util = require("gfx_util")

local function _print(text, x, y, w, h)
	gfx_util.printFrame(text, x, y, w, h, "center", "center")
end

local function print_values(w, h, ratio, name, value, right)
	local font = love.graphics.getFont()
	local nw = font:getWidth(name) + 20
	local vw = font:getWidth(value) + 20
	local fw = nw + vw
	local offset = vw > w * (1 - ratio) and vw or 0

	local x = 0
	local a = 1
	local b = 0
	if right then
		x = w
		a = -1
		b = -1
	end

	love.graphics.translate(x, 0)
	if fw > w then
		_print(name, b * nw, 0, nw, h)
		_print(value, a * nw + b * vw, 0, vw, h)
	elseif fw > w * (1 - ratio) or nw <= w * ratio then
		_print(name, b * nw, 0, nw, h)
		_print(value, a * math.max(nw, w * ratio - offset) + b * vw, 0, vw, h)
	else
		_print(name, a * w * ratio + b * nw, 0, nw, h)
		_print(value, a * (nw + w * ratio) + b * vw, 0, vw, h)
	end
	love.graphics.translate(-x, 0)
end

local shadow = 2
return function(w, h, ratio, name, value, right)
	love.graphics.setColor(1, 1, 1, 0.2)
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setColor(0.9, 0.7, 0, 1)
	love.graphics.rectangle("fill", right and w * (1 - ratio) or 0, 0, w * ratio, h)

	love.graphics.translate(shadow, shadow)
	love.graphics.setColor(0, 0, 0, 1)
	print_values(w, h, ratio, name, value, right)

	love.graphics.translate(-shadow, -shadow)
	love.graphics.setColor(1, 1, 1, 1)
	print_values(w, h, ratio, name, value, right)

	just.next(w, h)
end
