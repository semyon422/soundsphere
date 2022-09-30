local utf8 = require("utf8")
local just = require("just")

local size = 0.75
return function(id, text, index, w, h)
	local font = love.graphics.getFont()
	local lh = font:getHeight() * font:getLineHeight()
	h = h or lh

	local changed, active, hovered = just.button(id, just.is_over(w, h))
	if changed then
		just.focus(id)
	end

	just.push()

	local r = h * size / 2
	local x = h * (1 - size) / 2
	love.graphics.setColor(1, 1, 1, 0.2)
	if hovered then
		local alpha = active and 0.4 or 0.3
		love.graphics.setColor(1, 1, 1, alpha)
	end
	love.graphics.rectangle("fill", x, x, w - x * 2, h * size, r)

	love.graphics.translate(r, (h - lh) / 2)
	love.graphics.setColor(1, 1, 1, 1)

	local changed, left, right
	if just.focused_id == id then
		if just.keypressed("escape") then
			just.focus()
		end
		changed, text, index, left, right = just.textinput(text, index)
		just.text(left)
		just.sameline()
		love.graphics.line(1, lh * 0.15, 1, lh * 0.85)
		just.text(right)
	else
		index = utf8.len(text) + 1
		just.text(text)
	end

	just.pop()
	just.next(w, h)

	return changed, text, index
end
