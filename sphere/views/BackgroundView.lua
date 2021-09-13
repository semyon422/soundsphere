
local Class = require("aqua.util.Class")
local frame_draw = require("aqua.graphics.frame_draw")
local map = require("aqua.math").map
local transform = require("aqua.graphics.transform")
local GaussianBlurView = require("sphere.views.GaussianBlurView")
local inside = require("aqua.util.inside")

local BackgroundView = Class:new()

BackgroundView.construct = function(self)
	self.gaussianBlurView = GaussianBlurView:new()
end

BackgroundView.draw = function(self)
	local config = self.config

	local dim = config.dim.value or inside(self, config.dim.key)
	if dim == 1 then
		return
	end

	local blur = config.blur.value or inside(self, config.blur.key)
	if blur > 0 then
		return self:drawBlurBackground()
	end

	self:drawBackground()
end

BackgroundView.drawBlurBackground = function(self)
	local config = self.config

	local sigma = config.blur.value or inside(self, config.blur.key)
	if self.gaussianBlurView.sigma ~= sigma then
		self.gaussianBlurView:setSigma(sigma)
	end

	self.gaussianBlurView:enable()
	self:drawBackground()
	self.gaussianBlurView:disable()
end

BackgroundView.drawBackground = function(self)
	local config = self.config

	local tf = transform(config.transform)
	love.graphics.replaceTransform(tf)
	tf:release()

	local images = self.backgroundModel.images
	local alpha = self.backgroundModel.alpha

	local dim = 1 - (config.dim.value or inside(self, config.dim.key))
	local r, g, b = dim, dim, dim

	local mx, my = love.mouse.getPosition()
	local w, h = config.w, config.h
	for i = 1, 3 do
		if not images[i] then
			return
		end

		if i == 1 then
			love.graphics.setColor(r, g, b, 1)
		elseif i == 2 then
			love.graphics.setColor(r, g, b, alpha)
		elseif i == 3 then
			love.graphics.setColor(r, g, b, 0)
		end

		frame_draw(
			images[i],
			-map(mx, 0, w, config.parallax, 0) * w,
			-map(my, 0, h, config.parallax, 0) * h,
			(1 + 2 * config.parallax) * w,
			(1 + 2 * config.parallax) * h,
			"out"
		)
	end
end

return BackgroundView
