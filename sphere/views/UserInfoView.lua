
local just = require("just")
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local inside = require("aqua.util.inside")
local belong		= require("aqua.math").belong

local UserInfoView = Class:new()

UserInfoView.load = function(self)
	local config = self.config
	local state = self.state

	if not config.file or not love.filesystem.getInfo(config.file) then
		return
	end

	state.image = love.graphics.newImage(config.file)
end

UserInfoView.draw = function(self)
	local config = self.config
	local state = self.state

	local tf = transform(config.transform):translate(config.x, config.y)
	love.graphics.replaceTransform(tf)

	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local over = 0 <= x and x <= config.w and 0 <= y and y <= config.h

	local changed, active, hovered = just.button_behavior(self, over)
	if changed then
		self.navigator:call(config.action)
	end

	local font = spherefonts.get(config.text.font)
	love.graphics.setFont(font)
	love.graphics.setColor(1, 1, 1, 1)

	local username = config.username and inside(self, config.username) or ""
	baseline_print(
		username,
		config.text.x,
		config.text.baseline,
		config.text.limit,
		1,
		config.text.align
	)

	local image = state.image
	if state.image then
		love.graphics.draw(
			image,
			config.image.x,
			config.image.y,
			0,
			config.image.w / image:getWidth(),
			config.image.h / image:getHeight()
		)
	end

	love.graphics.circle(
		"line",
		config.image.x + config.image.w / 2,
		config.image.y + config.image.h / 2,
		config.image.h / 2
	)
	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.circle(
			"fill",
			config.image.x + config.image.w / 2,
			config.image.y + config.image.h / 2,
			config.image.h / 2
		)
	end

	local session = config.session and inside(self, config.session)
	if session and session.active then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.circle(
			"fill",
			config.marker.x,
			config.marker.y,
			config.marker.r
		)
		love.graphics.circle(
			"line",
			config.marker.x,
			config.marker.y,
			config.marker.r
		)
	end
end

return UserInfoView
