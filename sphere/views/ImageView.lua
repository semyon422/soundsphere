
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

	local w, h = state.imageWidth, state.imageHeight

	local cw, ch = config.w, config.h
	local sx = cw and cw / w or config.sx or 1
	local sy = ch and ch / h or config.sy or 1
	local ox = (config.ox or 0) * w
	local oy = (config.oy or 0) * h

	local tf = transform(config.transform)
	love.graphics.replaceTransform(tf)
	tf:release()

	love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        state.image,
		config.x,
		config.y,
        0,
		sx, sy, ox, oy
    )
end

return ImageView
