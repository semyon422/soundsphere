local just = require("just")

return function(id, text, limit)
	if not just.mouse_over(id, true, "mouse") then
		return
	end

	local _limit = limit or math.huge
	local font = love.graphics.getFont()
	local w, wrapped = font:getWrap(text, _limit)
	local h = font:getHeight() * #wrapped

	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	mx = mx + 20

	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle("fill", mx, my, limit or w, h)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(text, mx, my, _limit, "left")
end
