
local transform = require("aqua.graphics.transform")
local Class = require("aqua.util.Class")
local Animation = require("aqua.util.Animation")

local ImageAnimationView = Class:new()

ImageAnimationView.root = "."

ImageAnimationView.load = function(self)
	local config = self.config
	local state = self.state

	local animation = Animation:new()
	animation.cycles = config.cycles
	animation.range = config.range
	animation.rate = config.rate
	animation.time = math.huge
	state.animation = animation

	local images = {}
	for i = config.range[1], config.range[2] do
		images[i] = love.graphics.newImage(self.root .. "/" .. config.image:format(i))
	end
	state.images = images
end

ImageAnimationView.reset = function(self)
	self.state.animation.time = self.config.time
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

	local image = state.images[animation.frame]
	love.graphics.setColor(1, 1, 1, 1)
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
