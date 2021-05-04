
local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local spherefonts		= require("sphere.assets.fonts")

local SortStepperView = Class:new()

SortStepperView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

SortStepperView.draw = function(self)
	local cs = self.cs
	local config = self.config
	local screen = self.config.screen

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(config.text.fontFamily, config.text.fontSize)
	love.graphics.setFont(font)
	love.graphics.printf(
		"path",
		cs:X((config.x + config.text.x) / screen.h, true),
		cs:Y((config.y + config.text.y) / screen.h, true),
		config.text.w,
		config.text.align,
		0,
		cs.one / screen.h,
		cs.one / screen.h
	)

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

	local ty = config.frame.y + config.frame.h / 3
	local by = config.frame.y + 2 * config.frame.h / 3
	local my = config.frame.y + config.frame.h / 2

	local rx1 = config.frame.x + config.frame.h / 2
	local lx1 = rx1 - config.frame.h / 6

	local lx2 = rx1 + config.frame.w - config.frame.h
	local rx2 = lx2 + config.frame.h / 6

	love.graphics.polygon(
		"fill",
		cs:X((config.x + rx1) / screen.h, true), cs:Y((config.y + ty) / screen.h, true),
		cs:X((config.x + lx1) / screen.h, true), cs:Y((config.y + my) / screen.h, true),
		cs:X((config.x + rx1) / screen.h, true), cs:Y((config.y + by) / screen.h, true)
	)

	love.graphics.polygon(
		"fill",
		cs:X((config.x + lx2) / screen.h, true), cs:Y((config.y + ty) / screen.h, true),
		cs:X((config.x + rx2) / screen.h, true), cs:Y((config.y + my) / screen.h, true),
		cs:X((config.x + lx2) / screen.h, true), cs:Y((config.y + by) / screen.h, true)
	)
end

return SortStepperView
