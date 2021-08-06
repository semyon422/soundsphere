
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")

local SortStepperView = Class:new()

SortStepperView.draw = function(self)
	local config = self.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(config.text.fontFamily, config.text.fontSize)
	love.graphics.setFont(font)
	baseline_print(
		"path",
		config.text.x,
		config.text.baseline,
		config.text.limit,
		1,
		config.text.align
	)

	love.graphics.setLineWidth(config.frame.lineWidth)
	love.graphics.setLineStyle(config.frame.lineStyle)
	love.graphics.rectangle(
		"line",
		config.frame.x,
		config.frame.y,
		config.frame.w,
		config.frame.h,
		config.frame.h / 2,
		config.frame.h / 2
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
		rx1, ty,
		lx1, my,
		rx1, by
	)

	love.graphics.polygon(
		"fill",
		lx2, ty,
		rx2, my,
		lx2, by
	)
end

return SortStepperView
