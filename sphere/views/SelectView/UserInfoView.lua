
local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local UserInfoView = Class:new()

UserInfoView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

UserInfoView.draw = function(self)
	local cs = self.cs
	local config = self.config
	local screen = self.config.screen

	love.graphics.setColor(1, 1, 1, 1)

	local font = aquafonts.getFont(spherefonts.NotoSansRegular, config.text.fontSize)
	love.graphics.setFont(font)
	love.graphics.printf(
		"username",
		cs:X((config.x + config.text.x) / screen.h, true),
		cs:Y((config.y + config.text.y) / screen.h, true),
		config.text.w,
		config.text.align,
		0,
		cs.one / screen.h,
		cs.one / screen.h
	)

	love.graphics.circle(
		"fill",
		cs:X((config.x + config.image.x + config.image.w / 2) / screen.h, true),
		cs:Y((config.y + config.image.y + config.image.h / 2) / screen.h, true),
		cs:X(config.image.h / 2 / screen.h)
	)
end

return UserInfoView
