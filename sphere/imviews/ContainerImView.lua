local just = require("just")
local ScrollBarImView = require("sphere.imviews.ScrollBarImView")

local stack = {}

return function(id, w, h, _h, scrollY)
	if not id then
		local height_start
		id, _h, h, w, scrollY, height_start = unpack(table.remove(stack))

		just.container()
		local height = just.height - height_start
		just.clip()

		local over = just.is_over(w, h)
		local scroll = just.wheel_over(id, over)

		local overlap = math.max(height - h, 0)

		just.push()
		love.graphics.translate(w - 20, 0)
		scrollY = overlap * ScrollBarImView(id .. "scrollbar", scrollY / overlap, 20, h, overlap)
		if overlap > 0 and scroll then
			scrollY = math.min(math.max(scrollY - scroll * _h, 0), overlap)
		end
		if overlap == 0 then
			scrollY = 0
		end
		just.pop()

		just.next(w, h)

		return scrollY
	end

	table.insert(stack, {
		id, _h, h, w, scrollY, just.height
	})

	love.graphics.setColor(1, 1, 1, 1)
	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h)

	local over = just.is_over(w, h)
	just.container(id, over)
	just.mouse_over(id, over, "mouse")
	love.graphics.translate(0, -scrollY)
end
