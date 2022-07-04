
local transform = require("aqua.graphics.transform")
local newPixel = require("aqua.graphics.newPixel")
local FileFinder = require("sphere.filesystem.FileFinder")
local Class = require("aqua.util.Class")

local ImageView = Class:new()

ImageView.load = function(self)
	local path = FileFinder:findFile(self.image)
	if path then
		local status, image = pcall(love.graphics.newImage, path)
		if status then
			self.imageObject = image
		end
	end
	if not self.imageObject then
		self.imageObject = newPixel()
	end
	self.imageWidth = self.imageObject:getWidth()
	self.imageHeight = self.imageObject:getHeight()
end

ImageView.draw = function(self)
	local w, h = self.imageWidth, self.imageHeight

	local cw, ch = self.w, self.h
	local sx = cw and cw / w or self.sx or 1
	local sy = ch and ch / h or self.sy or 1
	local ox = (self.ox or 0) * w
	local oy = (self.oy or 0) * h

	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

	if self.color then
		love.graphics.setColor(self.color)
	else
		love.graphics.setColor(1, 1, 1, 1)
	end
    love.graphics.draw(
        self.imageObject,
		self.x,
		self.y,
        self.r or 0,
		sx, sy, ox, oy
    )
end

return ImageView
