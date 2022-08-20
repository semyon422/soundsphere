local just = require("just")
local just_print = require("just.print")

local height = 0
local height_start = 0
local width = 0
local open_frame_id
return function(id, w, h, preview)
	if not id then
		just.container()
		height = just.height - height_start
		just.clip()
		love.graphics.setColor(1, 1, 1, 1)
		if open_frame_id then
			open_frame_id = nil
			return
		end
		love.graphics.rectangle("line", 0, 0, width, height, 8, 8)
		just.next(width, height)
		return
	end

	if just.focused_id ~= id and just.button(id, just.is_over(w, h)) then
		just.focus(id)
		open_frame_id = id
	end
	if just.focused_id ~= id or open_frame_id == id then
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 0, 0, w, h, 8, 8)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle("line", 0, 0, w, h, 8, 8)
		just_print(preview, 0, 0, w, h, "center", "center")
		just.next(w, h)
		if open_frame_id == id then
			just.clip(love.graphics.rectangle, "fill", 0, 0, 0, 0)
			return true
		end
		return
	end

	height_start = just.height
	width = w

	love.graphics.setColor(1, 1, 1, 1)
	just.clip(love.graphics.rectangle, "fill", 0, 0, width, height, 8, 8)

	just.container(id, just.is_over(width, height))

	return true
end
