
local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")

local UserInfoView = Class:new()

UserInfoView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

UserInfoView.draw = function(self)
	local cs = self.cs
	local config = self.config
	local screen = self.config.screen

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(config.text.fontFamily, config.text.fontSize)
	love.graphics.setFont(font)
	baseline_print(
		"username",
		cs:X((config.x + config.text.x) / screen.h, true),
		cs:Y((config.y + config.text.baseline) / screen.h, true),
		config.text.limit,
		cs.one / screen.h,
		config.text.align
	)

	love.graphics.circle(
		"fill",
		cs:X((config.x + config.image.x + config.image.w / 2) / screen.h, true),
		cs:Y((config.y + config.image.y + config.image.h / 2) / screen.h, true),
		cs:X(config.image.h / 2 / screen.h)
	)
end

return UserInfoView
