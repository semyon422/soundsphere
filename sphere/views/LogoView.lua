
local Class = require("aqua.util.Class")
local spherefonts		= require("sphere.assets.fonts")
local logo		= require("sphere.views.logo")
local baseline_print = require("aqua.graphics.baseline_print")
local transform = require("aqua.graphics.transform")

local LogoView = Class:new()

LogoView.draw = function(self)
	local config = self.config

	local tf = transform(config.transform):translate(config.x, config.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(config.text.font)
	love.graphics.setFont(font)
	baseline_print(
		"soundsphere",
		config.text.x,
		config.text.baseline,
		config.text.limit,
		1,
		config.text.align
	)

	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(1)
    logo.draw(
        "line",
		config.image.x,
		config.image.y,
		config.image.h
    )
    logo.draw(
        "fill",
		config.image.x,
		config.image.y,
		config.image.h
    )
end

return LogoView
