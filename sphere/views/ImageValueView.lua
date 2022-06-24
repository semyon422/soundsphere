local transform = require("aqua.graphics.transform")
local inside = require("aqua.util.inside")
local FileFinder = require("sphere.filesystem.FileFinder")
local Class = require("aqua.util.Class")

local ImageValueView = Class:new()

ImageValueView.load = function(self)
	local images = {}
	for char, path in pairs(self.files) do
		images[char] = love.graphics.newImage(FileFinder:findFile(path))
	end
	self.images = images
end

ImageValueView.getDimensions = function(self, value)
	local images = self.images
	local overlap = self.overlap or 0

	local width = 0
	local height = 0
	for i = 1, #value do
		local char = value:sub(i, i)
		local image = images[char]
		if image then
			width = width + image:getWidth() - overlap
			height = math.max(height, image:getHeight())
		end
	end
	if width > 0 then
		width = width + overlap
	end
	return width, height
end

ImageValueView.draw = function(self)
	local images = self.images
	local overlap = self.overlap or 0

	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)

	local format = self.format
	local value = self.value or inside(self, self.key)
	if value then
		if type(value) == "function" then
			value = value(self)
		end
		if self.multiplier and tonumber(value) then
			value = value * self.multiplier
		end
		if type(format) == "string" then
			value = format:format(value)
		elseif type(format) == "function" then
			value = format(value)
		end
	end
	value = tostring(value)

	local sx = self.scale or self.sx or 1
	local sy = self.scale or self.sy or 1
	local oy = self.oy or 0
	local align = self.align

	local width, height = self:getDimensions(value)
	self.width = width
	self.height = height

	local x = self.x
	if align == "center" then
		x = x - width / 2 * sx
	elseif align == "right" then
		x = x - width * sx
	end
	for i = 1, #value do
		local char = value:sub(i, i)
		local image = images[char]
		if image then
			love.graphics.draw(image, x, self.y + (height * (1 - oy) - image:getHeight()) * sy, 0, sx, sy)
			x = x + (image:getWidth() - overlap) * sx
		end
	end
end

return ImageValueView
