local utf8 = require("utf8")
local just = require("just")

return function(id, text, index, w, h)
	local font = love.graphics.getFont()
	local lh = font:getHeight()
	h = h or lh

	if just.button(id, just.is_over(w, h)) then
		just.focus(id)
	end

	love.graphics.push()

	local r = 8
	love.graphics.rectangle("line", 0, 0, w, h, r)
	love.graphics.translate(r, (h - lh) / 2)

	local changed, left, right
	if just.focused_id == id then
		if just.keypressed("escape") then
			just.focus()
		end
		changed, text, index, left, right = just.textinput(text, index)
		just.text(left)
		just.sameline()
		love.graphics.line(0, 0, 0, lh)
		just.text(right)
	else
		index = utf8.len(text) + 1
		just.text(text)
	end

	love.graphics.pop()
	just.next(w, h)

	return changed, text, index
end
