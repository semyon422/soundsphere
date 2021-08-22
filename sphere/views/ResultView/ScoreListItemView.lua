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

	local fontRankName = spherefonts.get(config.rankName.fontFamily, config.rankName.fontSize)
	love.graphics.setFont(fontRankName)
	baseline_print(
		"rank",
		config.rankName.x,
		y + config.rankName.baseline,
		config.rankName.limit,
		1,
		config.rankName.align
	)

	local fontRankValue = spherefonts.get(config.rankValue.fontFamily, config.rankValue.fontSize)
	love.graphics.setFont(fontRankValue)
	baseline_print(
		0,
		config.rankValue.x,
		y + config.rankValue.baseline,
		config.rankValue.limit,
		1,
		config.rankValue.align
	)

	local fontPerformanceName = spherefonts.get(config.performanceName.fontFamily, config.performanceName.fontSize)
	love.graphics.setFont(fontPerformanceName)
	baseline_print(
		"pp",
		config.performanceName.x,
		y + config.performanceName.baseline,
		config.performanceName.limit,
		1,
		config.performanceName.align
	)

	local fontPerformanceValue = spherefonts.get(config.performanceValue.fontFamily, config.performanceValue.fontSize)
	love.graphics.setFont(fontPerformanceValue)
	baseline_print(
		0,
		config.performanceValue.x,
		y + config.performanceValue.baseline,
		config.performanceValue.limit,
		1,
		config.performanceValue.align
	)

	local fontPlayedName = spherefonts.get(config.playedName.fontFamily, config.playedName.fontSize)
	love.graphics.setFont(fontPlayedName)
	baseline_print(
		"played",
		config.playedName.x,
		y + config.playedName.baseline,
		config.playedName.limit,
		1,
		config.playedName.align
	)

	local fontPlayedValue = spherefonts.get(config.playedValue.fontFamily, config.playedValue.fontSize)
	love.graphics.setFont(fontPlayedValue)
	baseline_print(
		"0 seconds ago",
		config.playedValue.x,
		y + config.playedValue.baseline,
		config.playedValue.limit,
		1,
		config.playedValue.align
	)

	if true then
	-- if item.tagged then
		love.graphics.circle(
			"line",
			config.point.x,
			y + config.point.y,
			config.point.r
		)
		love.graphics.circle(
			"fill",
			config.point.x,
			y + config.point.y,
			config.point.r
		)
	end
end

return ScoreListItemView
