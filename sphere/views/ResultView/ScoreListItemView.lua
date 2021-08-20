local Class = require("aqua.util.Class")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local transform = require("aqua.graphics.transform")

local ScoreListItemView = Class:new()

ScoreListItemView.draw = function(self)
	local config = self.listView.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local y = (self.visualIndex - 1) * config.h / config.rows
	local item = self.item
	local scoreEntry = item.scoreEntry

	local fontName = spherefonts.get(config.performanceName.fontFamily, config.performanceName.fontSize)
	love.graphics.setFont(fontName)
	baseline_print(
		scoreEntry.score,
		config.performanceName.x,
		y + config.performanceName.baseline,
		config.performanceName.limit,
		1,
		config.performanceName.align
	)
end

return ScoreListItemView
