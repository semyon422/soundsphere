local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local NoteChartSetScrollBarView = Class:new()

NoteChartSetScrollBarView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

NoteChartSetScrollBarView.draw = function(self)
	local cs = self.cs
	local config = self.config
	local screen = self.config.screen

	love.graphics.setColor(1, 1, 1, 0.25)
	love.graphics.rectangle(
		"fill",
		cs:X(config.x / screen.h, true),
		cs:Y(config.y / screen.h, true),
		cs:X(config.w / screen.h),
		cs:Y(config.h / screen.h),
		cs:X(config.w / 2 / screen.h),
		cs:Y(config.w / 2 / screen.h)
	)

	local itemCount = #self.noteChartSetLibraryModel.items
	local rows = config.rows
	local noteChartSetItemIndex = self.selectModel.noteChartSetItemIndex
	local h = config.w + (config.h - config.w) * rows / (itemCount + rows)
	local y = config.y + (config.h - h) * (noteChartSetItemIndex - 1) / (itemCount - 1)

	love.graphics.setColor(1, 1, 1, 0.75)
	love.graphics.rectangle(
		"fill",
		cs:X(config.x / screen.h, true),
		cs:Y(y / screen.h, true),
		cs:X(config.w / screen.h),
		cs:Y(h / screen.h),
		cs:X(config.w / 2 / screen.h),
		cs:Y(config.w / 2 / screen.h)
	)
end

return NoteChartSetScrollBarView
