
local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local spherefonts		= require("sphere.assets.fonts")

local SearchFieldView = Class:new()

SearchFieldView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

SearchFieldView.draw = function(self)
	local cs = self.cs
	local config = self.config
	local screen = self.config.screen

	local searchString = self.searchLineModel.searchString
	if searchString == "" then
		love.graphics.setColor(1, 1, 1, 0.5)
		searchString = "Search..."
	else
		love.graphics.setColor(1, 1, 1, 1)
	end

	local font = spherefonts.get(config.text.fontFamily, config.text.fontSize)
	love.graphics.setFont(font)
	love.graphics.printf(
		searchString,
		cs:X((config.x + config.text.x) / screen.h, true),
		cs:Y((config.y + config.text.y) / screen.h, true),
		config.text.w,
		config.text.align,
		0,
		cs.one / screen.h,
		cs.one / screen.h
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
end

return SearchFieldView
