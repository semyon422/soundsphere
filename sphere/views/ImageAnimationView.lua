local transform = require("gfx_util").transform
local class = require("class")
local Animation = require("Animation")

---@class sphere.ImageAnimationView
---@operator call: sphere.ImageAnimationView
local ImageAnimationView = class()

function ImageAnimationView:load()
	local animation = Animation()
	animation.cycles = self.cycles or 1
	animation.range = self.range or {0, 0}
	animation.rate = self.rate
	animation.time = math.huge
	self.animation = animation
	self.color = self.color or { 1, 1, 1, 1 }
	self.rotation = self.rotation or 0

	if self.quad then
		self:loadQuads()
		return
	end
	self:loadImages()
end

function ImageAnimationView:loadImages()
	local fileFinder = self.game.fileFinder
	local images = {}
	local range = self.range
	if not range then
		images[0] = love.graphics.newImage(fileFinder:findFile(self.image))
	else
		for i = range[1], range[2], range[1] < range[2] and 1 or -1 do
			images[i] = love.graphics.newImage(fileFinder:findFile(self.image:format(i)))
		end
	end
	self.images = images
end

function ImageAnimationView:loadQuads()
	local image = love.graphics.newImage(self.game.fileFinder:findFile(self.image))
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

---@param time number
function ImageAnimationView:setTime(time)
	self.animation.time = time
end

---@param cycles number
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

	love.graphics.setColor(self.color)
	if self.quad then
		love.graphics.draw(
			self.image,
			self.quads[animation.frame],
			self.x,
			self.y,
			self.rotation,
			sx, sy, ox, oy
		)
		return
	end
	love.graphics.draw(
		self.images[animation.frame],
		self.x,
		self.y,
		self.rotation,
		sx, sy, ox, oy
	)
end

---@param dt number
function ImageAnimationView:update(dt)
	self.animation:update(dt)
end

return ImageAnimationView
