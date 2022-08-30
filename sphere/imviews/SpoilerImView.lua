local just = require("just")
local just_print = require("just.print")

local height = 0
local height_start = 0
local base_height = 0
local width = 0
local open_frame_id

local size = 0.75
return function(id, w, h, preview)
	if not id then
		just.container()
		height = just.height - height_start
		just.clip()
		love.graphics.setColor(1, 1, 1, 1)
		h = base_height
		if open_frame_id then
			just.next(width, h)
			open_frame_id = nil
			return
		end
		local r = h * size / 2
		local x = h * (1 - size) / 2
		love.graphics.rectangle("line", x, x, width - x * 2, height, r)
		just.next(width, height + x * 2)
		return
	end

	local r = h * size / 2
	local x = h * (1 - size) / 2
	base_height = h
	width = w
	local _w, _h = w - x * 2, h - x * 2

	local changed, active, hovered = just.button(id, just.is_over(w, h))
	if just.focused_id ~= id and changed then
		just.focus(id)
		open_frame_id = id
	end
	if just.focused_id ~= id or open_frame_id == id then
		love.graphics.setColor(1, 1, 1, 0.2)
		if hovered then
			local alpha = active and 0.4 or 0.3
			love.graphics.setColor(1, 1, 1, alpha)
		end
		love.graphics.rectangle("fill", x, x, _w, _h, r)
		love.graphics.setColor(1, 1, 1, 1)
		just_print(preview, x, x, _w, _h, "center", "center")
		if open_frame_id == id then
			just.clip(love.graphics.rectangle, "fill", 0, 0, 0, 0)
			return true
		end
		just.next(w, h)
		return
	end

	height_start = just.height

	love.graphics.setColor(1, 1, 1, 1)
	just.clip(love.graphics.rectangle, "fill", x, x, width - x * 2, height, r)

	local over = just.is_over(width, height)
	just.container(id, over)
	just.mouse_over(id, over, "mouse")
	love.graphics.translate(x, x)

	return true
end
