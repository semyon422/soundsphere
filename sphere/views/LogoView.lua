
local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local spherefonts		= require("sphere.assets.fonts")
local logo		= require("sphere.views.logo")
local baseline_print = require("aqua.graphics.baseline_print")

local LogoView = Class:new()

LogoView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

LogoView.draw = function(self)
	local cs = self.cs
	local config = self.config
	local screen = self.config.screen

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(config.text.fontFamily, config.text.fontSize)
	love.graphics.setFont(font)
	baseline_print(
		"soundsphere",
		cs:X((config.x + config.text.x) / screen.unit, true),
		cs:Y((config.y + config.text.baseline) / screen.unit, true),
		config.text.limit,
		cs.one / screen.unit,
		config.text.align
	)

	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(cs:X(1 / screen.unit))
    logo.draw(
        "line",
		cs:X((config.x + config.image.x) / screen.unit, true),
		cs:Y((config.y + config.image.y) / screen.unit, true),
		cs:X(config.image.h / screen.unit)
    )
    logo.draw(
        "fill",
		cs:X((config.x + config.image.x) / screen.unit, true),
		cs:Y((config.y + config.image.y) / screen.unit, true),
		cs:X(config.image.h / screen.unit)
    )
end

return LogoView
