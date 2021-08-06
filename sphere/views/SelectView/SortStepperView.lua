
local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")

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
	baseline_print(
		"path",
		cs:X((config.x + config.text.x) / screen.unit, true),
		cs:Y((config.y + config.text.baseline) / screen.unit, true),
		config.text.limit,
		cs.one / screen.unit,
		config.text.align
	)

	love.graphics.setLineWidth(cs:X(config.frame.lineWidth / screen.unit))
	love.graphics.setLineStyle(config.frame.lineStyle)
	love.graphics.rectangle(
		"line",
		cs:X((config.x + config.frame.x) / screen.unit, true),
		cs:Y((config.y + config.frame.y) / screen.unit, true),
		cs:X(config.frame.w / screen.unit),
		cs:Y(config.frame.h / screen.unit),
		cs:X(config.frame.h / 2 / screen.unit),
		cs:X(config.frame.h / 2 / screen.unit)
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
		cs:X((config.x + rx1) / screen.unit, true), cs:Y((config.y + ty) / screen.unit, true),
		cs:X((config.x + lx1) / screen.unit, true), cs:Y((config.y + my) / screen.unit, true),
		cs:X((config.x + rx1) / screen.unit, true), cs:Y((config.y + by) / screen.unit, true)
	)

	love.graphics.polygon(
		"fill",
		cs:X((config.x + lx2) / screen.unit, true), cs:Y((config.y + ty) / screen.unit, true),
		cs:X((config.x + rx2) / screen.unit, true), cs:Y((config.y + my) / screen.unit, true),
		cs:X((config.x + lx2) / screen.unit, true), cs:Y((config.y + by) / screen.unit, true)
	)
end

return SortStepperView
