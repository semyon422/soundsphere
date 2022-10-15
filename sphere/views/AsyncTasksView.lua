local spherefonts = require("sphere.assets.fonts")
local thread = require("thread")

return function()
	local w, h = love.graphics.getDimensions()
	love.graphics.origin()

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get("Noto Sans Mono", 14)
	love.graphics.setFont(font)

	local text = ("%d\n%d"):format(thread.current, thread.total)
	local twidth = font:getWidth(text)
	local theight = font:getHeight() * 2

	love.graphics.translate(0, h - theight)

	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle("fill", 0, 0, twidth, theight)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(text, 0, 0, twidth, "left")
end
