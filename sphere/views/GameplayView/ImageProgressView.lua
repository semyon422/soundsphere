local transform = require("gfx_util").transform
local RectangleProgressView = require("sphere.views.GameplayView.RectangleProgressView")
local ImageView = require("sphere.views.ImageView")

---@class sphere.ImageProgressView: sphere.RectangleProgressView
---@operator call: sphere.ImageProgressView
local ImageProgressView = RectangleProgressView + {}

function ImageProgressView:load()
	self.imageView = ImageView({image = self.image})
	self.imageView:load()

	self.w, self.h = self.imageView.imageObject:getDimensions()
	self.quad = love.graphics.newQuad(0, 0, 1, 1, self.imageView.imageObject)
end

function ImageProgressView:draw()
	local iw = self.imageView
	local w, h = iw.imageWidth, iw.imageHeight

	local sx = self.sx or 1
	local sy = self.sy or 1
	local ox = (self.ox or 0) * w
	local oy = (self.oy or 0) * h

	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

	if self.color then
		love.graphics.setColor(self.color)
	else
		love.graphics.setColor(1, 1, 1, 1)
	end

	local rx, ry, rw, rh = self:getRectangle()
	local quad = self.quad
	quad:setViewport(rx - self.x, ry - self.y, rw, rh, iw.imageObject:getDimensions())

	love.graphics.draw(
		iw.imageObject,
		quad,
		rx,
		ry,
		self.r or 0,
		sx, sy, ox, oy
	)
end

return ImageProgressView
