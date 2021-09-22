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
	animation.range = config.range
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
	for i = range[1], range[2], range[3] do
		images[i] = love.graphics.newImage(self.root .. "/" .. config.image:format(i))
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
	local offset = 0
	for i = range[1], range[2], range[3] do
		quads[i] = love.graphics.newQuad(q[1] + offset * q[3], q[2], q[3], q[4], w, h)
		offset = offset + 1
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

	local tf = transform(config.transform)
	love.graphics.replaceTransform(tf)
	tf:release()

	love.graphics.setColor(1, 1, 1, 1)
	if config.quad then
		local image = state.image
		love.graphics.draw(
			image,
			state.quads[animation.frame],
			config.x,
			config.y,
			0,
			config.w / image:getWidth(),
			config.h / image:getHeight()
		)
		return
	end
	local image = state.images[animation.frame]
	love.graphics.draw(
		image,
		config.x,
		config.y,
		0,
		config.w / image:getWidth(),
		config.h / image:getHeight()
	)
end

ImageAnimationView.update = function(self, dt)
	self.state.animation:update(dt)
end

return ImageAnimationView
