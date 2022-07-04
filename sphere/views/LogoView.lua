
local Class = require("aqua.util.Class")
local spherefonts		= require("sphere.assets.fonts")
local logo		= require("sphere.views.logo")
local baseline_print = require("aqua.graphics.baseline_print")
local transform = require("aqua.graphics.transform")

local LogoView = Class:new()

LogoView.draw = function(self)
	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)

	if self.text then
		local font = spherefonts.get(self.text.font)
		love.graphics.setFont(font)
		baseline_print(
			"soundsphere",
			self.text.x,
			self.text.baseline,
			self.text.limit,
			1,
			self.text.align
		)
	end

	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(1)
    logo.draw(
        "line",
		self.image.x,
		self.image.y,
		self.image.h
    )
    logo.draw(
        "fill",
		self.image.x,
		self.image.y,
		self.image.h
    )
end

return LogoView
