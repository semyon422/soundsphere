
local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local baseline_print = require("aqua.graphics.baseline_print")
local spherefonts		= require("sphere.assets.fonts")

local SearchFieldView = Class:new()

SearchFieldView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

SearchFieldView.draw = function(self)
	local cs = self.cs
	local config = self.config
	local screen = self.config.screen

	local searchString = self.searchModel.searchString
	if searchString == "" then
		love.graphics.setColor(1, 1, 1, 0.5)
		searchString = "Search..."
	else
		love.graphics.setColor(1, 1, 1, 1)
	end

	local font = spherefonts.get(config.text.fontFamily, config.text.fontSize)
	love.graphics.setFont(font)
	baseline_print(
		searchString,
		cs:X((config.x + config.text.x) / screen.h, true),
		cs:Y((config.y + config.text.baseline) / screen.h, true),
		config.text.limit,
		cs.one / screen.h,
		config.text.align
	)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineWidth(cs:X(config.frame.lineWidth / screen.h))
	love.graphics.setLineStyle(config.frame.lineStyle)
	love.graphics.rectangle(
		"line",
		cs:X((config.x + config.frame.x) / screen.h, true),
		cs:Y((config.y + config.frame.y) / screen.h, true),
		cs:X(config.frame.w / screen.h),
		cs:Y(config.frame.h / screen.h),
		cs:X(config.frame.h / 2 / screen.h),
		cs:X(config.frame.h / 2 / screen.h)
	)

	if self.searchModel.searchMode == "show" then
		love.graphics.circle(
			"line",
			cs:X((config.x + config.frame.x + config.frame.w - config.frame.h / 2) / screen.h, true),
			cs:Y((config.y + config.frame.y + config.frame.h / 2) / screen.h, true),
			cs:X(config.point.r / screen.h)
		)
		love.graphics.circle(
			"fill",
			cs:X((config.x + config.frame.x + config.frame.w - config.frame.h / 2) / screen.h, true),
			cs:Y((config.y + config.frame.y + config.frame.h / 2) / screen.h, true),
			cs:X(config.point.r / screen.h)
		)
	end
end

return SearchFieldView
