local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Class = require("aqua.util.Class")

local ImageView = Class:new()

ImageView.load = function(self)
	local config = self.config
	local state = self.state

	state.cs = CoordinateManager:getCS(unpack(config.cs))
	state.imageReleased = love.graphics.newImage(self.root .. "/" .. config.released)
	state.imagePressed = love.graphics.newImage(self.root .. "/" .. (config.pressed or config.released))
	state.imageWidth = state.imageReleased:getWidth()
	state.imageHeight = state.imageReleased:getHeight()

    state.image = state.imageReleased
end

ImageView.draw = function(self)
	local config = self.config
	local state = self.state

	local cs = state.cs

	love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        state.image,
		cs:X(config.x, true),
		cs:Y(config.y, true),
        0,
        cs:X(1) / state.imageWidth * config.w,
	    cs:Y(1) / state.imageHeight * config.h
    )
end

ImageView.receive = function(self, event)
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

ImageView.update = function(self, dt) end
ImageView.unload = function(self) end

return ImageView
