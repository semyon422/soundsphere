local aquafonts			= require("aqua.assets.fonts")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local frame_print		= require("aqua.graphics.frame_print")
local Class = require("aqua.util.Class")

local MetaDataView = Class:new()

MetaDataView.load = function(self)
	local config = self.config
	local state = self.state

	state.cs = CoordinateManager:getCS(unpack(config.cs))
	state.font = aquafonts.getFont(config.font, config.size)
end

MetaDataView.draw = function(self)
	local config = self.config
	local state = self.state

	local cs = state.cs

	love.graphics.setFont(state.font)
	love.graphics.setColor(config.color)
	frame_print(
		(config.format):format(self.noteChartModel.noteChartDataEntry[config.field] or ""),
		cs:X(config.x, true),
		cs:Y(config.y, true),
		cs:X(config.w),
		cs:Y(config.h),
		cs.one / cs.baseOne,
		config.ax,
		config.ay
	)
end

MetaDataView.update = function(self, dt) end
MetaDataView.receive = function(self, event) end
MetaDataView.unload = function(self) end

return MetaDataView
