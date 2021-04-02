local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Class = require("aqua.util.Class")

local ImageView = Class:new()

ImageView.load = function(self)
	local config = self.config
	local state = self.state

	state.cs = CoordinateManager:getCS(unpack(config.cs))
	state.image = love.graphics.newImage(self.root .. "/" .. config.image)
	state.imageWidth = state.image:getWidth()
	state.imageHeight = state.image:getHeight()
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

ImageView.update = function(self, dt) end
ImageView.receive = function(self, event) end
ImageView.unload = function(self) end

return ImageView
