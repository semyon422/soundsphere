local transform = require("gfx_util").transform
local FileFinder = require("sphere.filesystem.FileFinder")
local class = require("class")
local Animation = require("Animation")

local ImageAnimationView = class()

function ImageAnimationView:load()
	local animation = Animation()
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

function ImageAnimationView:loadImages()
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

function ImageAnimationView:loadQuads()
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

function ImageAnimationView:setTime(time)
	self.animation.time = time
end

function ImageAnimationView:setCycles(cycles)
	self.animation.cycles = cycles
end

function ImageAnimationView:draw()
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

	if self.color then
		love.graphics.setColor(self.color)
	else
		love.graphics.setColor(1, 1, 1, 1)
	end
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

function ImageAnimationView:update(dt)
	self.animation:update(dt)
end

return ImageAnimationView
