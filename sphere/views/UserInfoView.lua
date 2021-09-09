
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local inside = require("aqua.util.inside")

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

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(config.text.fontFamily, config.text.fontSize)
	love.graphics.setFont(font)

	local value = config.value or inside(self, config.key)
	baseline_print(
		value,
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
end

return UserInfoView
