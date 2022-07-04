local just = require("just")
local icons = require("sphere.assets.icons")

local IconButtonView = {}

local images = {}
local function getImage(name)
	if not images[name] then
		images[name] = love.graphics.newImage(icons[name])
	end
	return images[name]
end

IconButtonView.draw = function(self, id, name, size, scale)
	local image = getImage(name)
	local width = image:getWidth()

	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local over = 0 <= mx and mx <= size and 0 <= my and my <= size

	local changed, active, hovered = just.button_behavior(id, over)
	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, size, size)
	end
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.draw(image, size * (1 - scale) / 2, size * (1 - scale) / 2, 0, size / width * scale)

	just.nextline(size, size)

	return changed
end

return IconButtonView
