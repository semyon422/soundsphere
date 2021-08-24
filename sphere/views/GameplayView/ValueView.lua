local spherefonts = require("sphere.assets.fonts")
local transform = require("aqua.graphics.transform")
local baseline_print = require("aqua.graphics.baseline_print")
local inside = require("aqua.util.inside")
local Class = require("aqua.util.Class")

local ValueView = Class:new()

ValueView.load = function(self)
	local config = self.config
	local state = self.state

	state.font = spherefonts.get(config.fontFamily, config.fontSize)
end

ValueView.getValue = function(self, field)
	if type(field) == "number" then
		return field
	end
	return inside(self, field)
end

ValueView.draw = function(self)
	local config = self.config

	love.graphics.replaceTransform(transform(config.transform))

	love.graphics.setFont(self.state.font)
	love.graphics.setColor(config.color)

	baseline_print(
		(config.format):format(self:getValue(config.field)),
		config.x,
		config.baseline,
		config.limit,
		1,
		config.align
	)
end

ValueView.update = function(self, dt) end
ValueView.receive = function(self, event) end
ValueView.unload = function(self) end

return ValueView
