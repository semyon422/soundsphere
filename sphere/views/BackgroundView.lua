
local Class = require("aqua.util.Class")
local frame_draw = require("aqua.graphics.frame_draw")
local map = require("aqua.math").map
local transform = require("aqua.graphics.transform")
local GaussianBlurView = require("sphere.views.GaussianBlurView")

local BackgroundView = Class:new()

BackgroundView.blurSigma = 16

BackgroundView.construct = function(self)
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
	local config = self.config

	love.graphics.replaceTransform(transform(config.transform))

	local images = self.backgroundModel.images
	local alpha = self.backgroundModel.alpha

	local r, g, b = config.dim, config.dim, config.dim

	local mx, my = love.mouse.getPosition()
	local w0, h0 = love.graphics.inverseTransformPoint(0, 0)
	local w1, h1 = love.graphics.inverseTransformPoint(love.graphics.getDimensions())
	local w, h = math.abs(w1 - w0), math.abs(h1 - h0)
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

		-- frame_draw(
		-- 	images[i],
		-- 	w0,
		-- 	h0,
		-- 	w,
		-- 	h,
		-- 	"out"
		-- )
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
