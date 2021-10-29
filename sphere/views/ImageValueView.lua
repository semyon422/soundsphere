local transform = require("aqua.graphics.transform")
local inside = require("aqua.util.inside")
local Class = require("aqua.util.Class")

local ImageValueView = Class:new()

ImageValueView.load = function(self)
	local config = self.config
	local state = self.state

	local images = {}
	for char, path in pairs(config.files) do
		images[char] = love.graphics.newImage(self.root .. "/" .. path)
	end
	state.images = images
end

ImageValueView.getWidth = function(self, value)
	local config = self.config
	local state = self.state
	local images = state.images
	local overlap = config.overlap or 0

	local width = 0
	for i = 1, #value do
		local char = value:sub(i, i)
		local image = images[char]
		if image then
			width = width + image:getWidth() - overlap
		end
	end
	if width > 0 then
		width = width + overlap
	end
	return width
end

ImageValueView.draw = function(self)
	local config = self.config
	local state = self.state
	local images = state.images
	local overlap = config.overlap or 0

	local tf = transform(config.transform)
	love.graphics.replaceTransform(tf)
	tf:release()

	love.graphics.setColor(1, 1, 1, 1)

	local format = config.format
	local value = config.value or inside(self, config.key)
	if value then
		if type(value) == "function" then
			value = value(self)
		end
		if config.multiplier and tonumber(value) then
			value = value * config.multiplier
		end
		if type(format) == "string" then
			value = format:format(value)
		elseif type(format) == "function" then
			value = format(value)
		end
	end
	value = tostring(value)

	local sx = config.scale or config.sx or 1
	local sy = config.scale or config.sy or 1

	local width = self:getWidth(value) * sx

	local x = config.x - width / 2
	for i = 1, #value do
		local char = value:sub(i, i)
		local image = images[char]
		if image then
			love.graphics.draw(image, x, config.y - image:getHeight() / 2 * sy, 0, sx, sy)
			x = x + (image:getWidth() - overlap) * sx
		end
	end
end

return ImageValueView
