
local transform = require("aqua.graphics.transform")
local Class = require("aqua.util.Class")

local InputImageView = Class:new()

InputImageView.load = function(self)
	local config = self.config
	local state = self.state

	state.imageReleased = love.graphics.newImage(self.root .. "/" .. config.released)
	state.imagePressed = love.graphics.newImage(self.root .. "/" .. (config.pressed or config.released))
	state.imageWidth = state.imageReleased:getWidth()
	state.imageHeight = state.imageReleased:getHeight()

    state.image = state.imageReleased
end

InputImageView.draw = function(self)
	local config = self.config
	local state = self.state

	local tf = transform(config.transform)
	love.graphics.replaceTransform(tf)
	tf:release()

	love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        state.image,
		config.x,
		config.y,
        0,
        config.w / state.imageWidth,
	    config.h / state.imageHeight
    )
end

InputImageView.receive = function(self, event)
	local state = self.state

	local key = event.args and event.args[1]
	if key == self.keyBind then
		if event.name == "keypressed" then
			state.image = state.imagePressed
		elseif event.name == "keyreleased" then
			state.image = state.imageReleased
		end
	end
end

InputImageView.update = function(self, dt) end
InputImageView.unload = function(self) end

return InputImageView
