local aquafonts			= require("aqua.assets.fonts")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local frame_print		= require("aqua.graphics.frame_print")
local Class = require("aqua.util.Class")

local ValueView = Class:new()

ValueView.load = function(self)
	local config = self.config
	local state = self.state

	state.cs = CoordinateManager:getCS(unpack(config.cs))
	state.font = aquafonts.getFont(config.font, config.size)
end

ValueView.getValue = function(self)
	local config = self.config
	local state = self.state

	local value = self
	for key in config.field:gmatch("[^.]+") do
		value = value[key]
	end
	return value
end

ValueView.draw = function(self)
	local config = self.config
	local state = self.state

	local cs = state.cs

	local value = self:getValue()

	love.graphics.setFont(state.font)
	love.graphics.setColor(config.color)
	frame_print(
		(config.format):format(self:getValue()),
		cs:X(config.x, true),
		cs:Y(config.y, true),
		cs:X(config.w),
		cs:Y(config.h),
		cs.one / cs.baseOne,
		config.ax,
		config.ay
	)
end

ValueView.update = function(self, dt) end
ValueView.receive = function(self, event) end
ValueView.unload = function(self) end

return ValueView
