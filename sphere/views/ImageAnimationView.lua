local transform = require("aqua.graphics.transform")
local Class = require("aqua.util.Class")
local Animation = require("aqua.util.Animation")

local ImageAnimationView = Class:new()

ImageAnimationView.root = "."

ImageAnimationView.load = function(self)
	local config = self.config
	local state = self.state

	local animation = Animation:new()
	animation.cycles = 1
	animation.range = config.range or {0, 0}
	animation.rate = config.rate
	animation.time = math.huge
	state.animation = animation

	if config.quad then
		return self:loadQuads()
	end
	return self:loadImages()
end

ImageAnimationView.loadImages = function(self)
	local config = self.config
	local state = self.state

	local images = {}
	local range = config.range
	if not range then
		images[0] = love.graphics.newImage(self.root .. "/" .. config.image)
	else
		for i = range[1], range[2], range[1] < range[2] and 1 or -1 do
			images[i] = love.graphics.newImage(self.root .. "/" .. config.image:format(i))
		end
	end
	state.images = images
end

ImageAnimationView.loadQuads = function(self)
	local config = self.config
	local state = self.state

	local image = love.graphics.newImage(self.root .. "/" .. config.image)
	local w, h = image:getDimensions()
	state.image = image

	local q = config.quad
	local quads = {}
	local range = config.range
	for i = range[1], range[2], range[1] < range[2] and 1 or -1 do
		quads[i] = love.graphics.newQuad(q[1] + i * q[3], q[2], q[3], q[4], w, h)
	end
	state.quads = quads
end

ImageAnimationView.setTime = function(self, time)
	self.state.animation.time = time
end

ImageAnimationView.setCycles = function(self, cycles)
	self.state.animation.cycles = cycles
end

ImageAnimationView.draw = function(self)
	local config = self.config
	local state = self.state

	local animation = state.animation
	if not animation.frame then
		return
	end

	local w, h
	if config.quad then
		w, h = config.quad[3], config.quad[4]
	else
		local image = state.images[animation.frame]
		w, h = image:getWidth(), image:getHeight()
	end

	local cw, ch = config.w, config.h
	local sx = cw and cw / w or config.sx or 1
	local sy = ch and ch / h or config.sy or 1
	local ox = (config.ox or 0) * w
	local oy = (config.oy or 0) * h

	local tf = transform(config.transform)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)
	if config.quad then
		love.graphics.draw(
			state.image,
			state.quads[animation.frame],
			config.x,
			config.y,
			0,
			sx, sy, ox, oy
		)
		return
	end
	love.graphics.draw(
		state.images[animation.frame],
		config.x,
		config.y,
		0,
		sx, sy, ox, oy
	)
end

ImageAnimationView.update = function(self, dt)
	self.state.animation:update(dt)
end

return ImageAnimationView
