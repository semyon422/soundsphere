
local Class = require("Class")
local spherefonts		= require("sphere.assets.fonts")
local logo		= require("sphere.views.logo")
local gfx_util = require("gfx_util")

local LogoView = Class:new()

LogoView.image = {
	x = 21,
	y = 20,
	w = 48,
	h = 48
}

LogoView.draw = function(self)
	local tf = gfx_util.transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)

	if self.text then
		love.graphics.setFont(spherefonts.get(unpack(self.text.font)))
		gfx_util.printBaseline(
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
