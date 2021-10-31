local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local ProgressView	= require("sphere.views.GameplayView.ProgressView")
local ImageView	= require("sphere.views.ImageView")

local ImageProgressView = Class:new()

ImageProgressView.getRectangle = ProgressView.getRectangle

ImageProgressView.load = function(self)
	ImageView.load(self)

	local config = self.config
	local state = self.state

	config.w, config.h = state.image:getDimensions()
	local rx, ry, rw, rh = self:getRectangle()
	state.quad = love.graphics.newQuad(rx - config.x, ry - config.y, rw, rh, state.image)
end

ImageProgressView.draw = function(self)
	local config = self.config
	local state = self.state

	local w, h = state.imageWidth, state.imageHeight

	local cw, ch = config.w, config.h
	local sx = config.sx or 1
	local sy = config.sy or 1
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

	local rx, ry, rw, rh = self:getRectangle()
	local quad = state.quad
	quad:setViewport(rx - config.x, ry - config.y, rw, rh, state.image:getDimensions())

	love.graphics.draw(
		state.image,
		quad,
		rx,
		ry,
		config.r or 0,
		sx, sy, ox, oy
	)
end

return ImageProgressView
