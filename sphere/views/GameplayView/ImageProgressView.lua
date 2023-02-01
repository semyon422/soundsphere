local transform = require("gfx_util").transform
local ProgressView	= require("sphere.views.GameplayView.ProgressView")
local ImageView	= require("sphere.views.ImageView")

local ImageProgressView = ProgressView:new()

ImageProgressView.load = function(self)
	ImageView.load(self)

	self.w, self.h = self.imageObject:getDimensions()
	self.quad = love.graphics.newQuad(0, 0, 1, 1, self.imageObject)
end

ImageProgressView.draw = function(self)
	local w, h = self.imageWidth, self.imageHeight

	local cw, ch = self.w, self.h
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
	quad:setViewport(rx - self.x, ry - self.y, rw, rh, self.imageObject:getDimensions())

	love.graphics.draw(
		self.imageObject,
		quad,
		rx,
		ry,
		self.r or 0,
		sx, sy, ox, oy
	)
end

return ImageProgressView
