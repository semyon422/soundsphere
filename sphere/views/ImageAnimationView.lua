local transform = require("aqua.graphics.transform")
local FileFinder = require("sphere.filesystem.FileFinder")
local Class = require("aqua.util.Class")
local Animation = require("aqua.util.Animation")

local ImageAnimationView = Class:new()

ImageAnimationView.load = function(self)
	local animation = Animation:new()
	animation.cycles = 1
	animation.range = self.range or {0, 0}
	animation.rate = self.rate
	animation.time = math.huge
	self.animation = animation

	if self.quad then
		return self:loadQuads()
	end
	return self:loadImages()
end

ImageAnimationView.loadImages = function(self)
	local images = {}
	local range = self.range
	if not range then
		images[0] = love.graphics.newImage(FileFinder:findFile(self.image))
	else
		for i = range[1], range[2], range[1] < range[2] and 1 or -1 do
			images[i] = love.graphics.newImage(FileFinder:findFile(self.image:format(i)))
		end
	end
	self.images = images
end

ImageAnimationView.loadQuads = function(self)
	local image = love.graphics.newImage(FileFinder:findFile(self.image))
	local w, h = image:getDimensions()
	self.image = image

	local q = self.quad
	local quads = {}
	local range = self.range
	for i = range[1], range[2], range[1] < range[2] and 1 or -1 do
		quads[i] = love.graphics.newQuad(q[1] + i * q[3], q[2], q[3], q[4], w, h)
	end
	self.quads = quads
end

ImageAnimationView.setTime = function(self, time)
	self.animation.time = time
end

ImageAnimationView.setCycles = function(self, cycles)
	self.animation.cycles = cycles
end

ImageAnimationView.draw = function(self)
	local animation = self.animation
	if not animation.frame then
		return
	end

	local w, h
	if self.quad then
		w, h = self.quad[3], self.quad[4]
	else
		local image = self.images[animation.frame]
		w, h = image:getWidth(), image:getHeight()
	end

	local cw, ch = self.w, self.h
	local sx = cw and cw / w or self.sx or 1
	local sy = ch and ch / h or self.sy or 1
	local ox = (self.ox or 0) * w
	local oy = (self.oy or 0) * h

	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)
	if self.quad then
		love.graphics.draw(
			self.image,
			self.quads[animation.frame],
			self.x,
			self.y,
			0,
			sx, sy, ox, oy
		)
		return
	end
	love.graphics.draw(
		self.images[animation.frame],
		self.x,
		self.y,
		0,
		sx, sy, ox, oy
	)
end

ImageAnimationView.update = function(self, dt)
	self.animation:update(dt)
end

return ImageAnimationView
