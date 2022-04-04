
local transform = require("aqua.graphics.transform")
local newPixel = require("aqua.graphics.newPixel")
local Class = require("aqua.util.Class")

local ImageView = Class:new()

ImageView.root = "."

ImageView.load = function(self)
	local config = self.config
	local state = self.state

	if config.image then
		state.image = love.graphics.newImage(self.root .. "/" .. config.image)
	else
		state.image = newPixel()
	end
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

	if config.color then
		love.graphics.setColor(config.color)
	else
		love.graphics.setColor(1, 1, 1, 1)
	end
    love.graphics.draw(
        state.image,
		config.x,
		config.y,
        config.r or 0,
		sx, sy, ox, oy
    )
end

return ImageView
