local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local spherefonts = require("sphere.assets.fonts")
local inside = require("aqua.util.inside")
local inspect = require("inspect")

local InspectView = Class:new()

InspectView.draw = function(self)
	local config = self.config

	local tf = transform(config.transform):translate(config.x, config.y)
	love.graphics.replaceTransform(tf)
	tf:release()

	love.graphics.setColor(1, 1, 1, 1)

	local value = config.value or inside(self, config.key) or 0

	local fontName = spherefonts.get(config.font)
	love.graphics.setFont(fontName)
	love.graphics.printf(
		inspect(value),
		config.x,
		config.y,
		config.limit,
		config.align
	)
end

return InspectView
