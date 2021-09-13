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

ValueView.draw = function(self)
	local config = self.config

	local tf = transform(config.transform)
	love.graphics.replaceTransform(tf)
	tf:release()

	love.graphics.setFont(self.state.font)
	love.graphics.setColor(config.color)

	local format = config.format
	local value = config.value or inside(self, config.key)
	if value then
		if config.multiplier and tonumber(value) then
			value = value * config.multiplier
		end
		if type(format) == "string" then
			value = format:format(value)
		elseif type(format) == "function" then
			value = format(value)
		end
	end

	baseline_print(
		tostring(value),
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
