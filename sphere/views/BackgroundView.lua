
local Class = require("aqua.util.Class")
local frame_draw = require("aqua.graphics.frame_draw")
local map = require("aqua.math").map
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local GaussianBlurView = require("sphere.views.GaussianBlurView")

local BackgroundView = Class:new()

BackgroundView.blurSigma = 16

BackgroundView.construct = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
	self.gaussianBlurView = GaussianBlurView:new()
end

BackgroundView.draw = function(self)
	local config = self.config

	if config.dim == 1 then
		return
	end

	if config.blur then
		return self:drawBlurBackground()
	end

	self:drawBackground()
end

BackgroundView.drawBlurBackground = function(self)
	local config = self.config
	if config.sigma and self.gaussianBlurView.sigma ~= config.sigma then
		self.gaussianBlurView:setSigma(config.sigma)
	end

	self.gaussianBlurView:enable()
	self:drawBackground()
	self.gaussianBlurView:disable()
end

BackgroundView.drawBackground = function(self)
	local cs = self.cs
	local config = self.config

	local images = self.backgroundModel.images
	local alpha = self.backgroundModel.alpha

	local r, g, b = config.dim, config.dim, config.dim

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

		local mx = cs:x(love.mouse.getX(), true)
		local my = cs:y(love.mouse.getY(), true)
		frame_draw(
			images[i],
			cs:X(0 - map(mx, 0, 1, config.parallax, 0), true),
			cs:Y(0 - map(my, 0, 1, config.parallax, 0), true),
			cs:X(1 + 2 * config.parallax),
			cs:Y(1 + 2 * config.parallax),
			"out"
		)
	end
end

return BackgroundView
