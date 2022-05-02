
local transform = require("aqua.graphics.transform")
local map				= require("aqua.math").map
local Class				= require("aqua.util.Class")
local inside = require("aqua.util.inside")

local HitErrorView = Class:new()

HitErrorView.draw = function(self)
	local state = self.state
	local config = self.config

	if config.show and not config.show(self) then
		return
	end

	local tf = transform(config.transform):translate(config.x, config.y)
	love.graphics.replaceTransform(tf)

	if config.background then
		self:drawBackground()
	end

	local points = inside(self, config.key)
	local fade = 0
	for i = #points, #points - config.count, -1 do
		if not points[i] then
			break
		end
		self:drawPoint(points[i], fade)
		fade = fade + 1
	end

	if config.origin then
		self:drawOrigin()
	end
end

HitErrorView.drawBackground = function(self)
	local config = self.config
	local state = self.state

	love.graphics.setColor(config.background.color)
	love.graphics.rectangle(
		"fill",
		-config.w / 2,
		0,
		config.w,
		config.h
	)
end

HitErrorView.drawOrigin = function(self)
	local config = self.config
	local state = self.state

	local origin = config.origin

	love.graphics.setColor(origin.color)
	love.graphics.rectangle(
		"fill",
		-origin.w / 2,
		-(origin.h - config.h) / 2,
		origin.w,
		origin.h
	)
end

HitErrorView.drawPoint = function(self, point, fade)
	local config = self.config
	local state = self.state

	local color = config.color
	local radius = config.radius

	local value = inside(point, config.value)
	local unit = inside(point, config.unit)
	if type(value) == "nil" then
		value = tonumber(config.value) or 0
	end
	if type(unit) == "nil" then
		unit = tonumber(config.unit) or 1
	end

	if type(color) == "function" then
		color = color(value, unit)
	end
	local alpha = color[4]
	color[4] = color[4] * map(fade, 0, config.count, 1, 0)
	love.graphics.setColor(color)
	color[4] = alpha

	local x = map(value, 0, unit, 0, config.w / 2)
	love.graphics.rectangle("fill", x - radius, 0, radius * 2, config.h)
end

return HitErrorView
