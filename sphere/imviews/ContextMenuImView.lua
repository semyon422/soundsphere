local just = require("just")

local height = 0
local height_start = 0
local width = 0
local over = false
local ix, iy
return function(w)
	if not w or w == true then
		just.container()
		height = just.height - height_start
		just.clip()
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle("line", 0, 0, width, height, 8, 8)
		if just.button("close context menu", not over) or w then
			height, height_start = 0, 0
			ix, iy = nil, nil
			return true
		end
		return
	end

	height_start = just.height
	width = w

	if not ix then
		ix, iy = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	end
	love.graphics.translate(ix, iy)

	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle("fill", 0, 0, width, height, 8, 8)
	love.graphics.setColor(1, 1, 1, 1)

	just.clip(love.graphics.rectangle, "fill", 0, 0, width, height, 8, 8)

	over = just.is_over(width, height)
	just.container("ContextMenuImView", over)

	return true
end
