local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local ScrollBarView = Class:new()

ScrollBarView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

ScrollBarView.draw = function(self)
	local cs = self.cs
	local config = self.config
	local screen = config.screen

	love.graphics.setColor(config.backgroundColor)
	love.graphics.rectangle(
		"fill",
		cs:X(config.x / screen.unit, true),
		cs:Y(config.y / screen.unit, true),
		cs:X(config.w / screen.unit),
		cs:Y(config.h / screen.unit),
		cs:X(config.w / 2 / screen.unit),
		cs:Y(config.w / 2 / screen.unit)
	)

	local listViewConfig = config.list
	local listViewState = self.sequenceView:getState(listViewConfig)

	local itemCount = #listViewState.items
	local rows = listViewConfig.rows
	local h = config.w + (config.h - config.w) * rows / (itemCount + rows)
	local y = config.y + (config.h - h) * (listViewState.selectedVisualItem - 1) / (itemCount - 1)

	love.graphics.setColor(config.color)
	love.graphics.rectangle(
		"fill",
		cs:X(config.x / screen.unit, true),
		cs:Y(y / screen.unit, true),
		cs:X(config.w / screen.unit),
		cs:Y(h / screen.unit),
		cs:X(config.w / 2 / screen.unit),
		cs:Y(config.w / 2 / screen.unit)
	)
end

return ScrollBarView
