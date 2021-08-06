
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local baseline_print = require("aqua.graphics.baseline_print")
local spherefonts		= require("sphere.assets.fonts")

local SearchFieldView = Class:new()

SearchFieldView.draw = function(self)
	local config = self.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)

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
		config.text.x,
		config.text.baseline,
		config.text.limit,
		1,
		config.text.align
	)

	love.graphics.setColor(1, 1, 1, 1)
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

	if self.searchModel.searchMode == "show" then
		love.graphics.circle(
			"line",
			config.frame.x + config.frame.w - config.frame.h / 2,
			config.frame.y + config.frame.h / 2,
			config.point.r
		)
		love.graphics.circle(
			"fill",
			config.frame.x + config.frame.w - config.frame.h / 2,
			config.frame.y + config.frame.h / 2,
			config.point.r
		)
	end
end

return SearchFieldView
