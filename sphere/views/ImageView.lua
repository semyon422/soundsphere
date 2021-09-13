
local transform = require("aqua.graphics.transform")
local Class = require("aqua.util.Class")

local ImageView = Class:new()

ImageView.root = "."

ImageView.load = function(self)
	local config = self.config
	local state = self.state

	state.image = love.graphics.newImage(self.root .. "/" .. config.image)
	state.imageWidth = state.image:getWidth()
	state.imageHeight = state.image:getHeight()
end

ImageView.draw = function(self)
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

ImageView.update = function(self, dt) end
ImageView.receive = function(self, event) end
ImageView.unload = function(self) end

return ImageView
