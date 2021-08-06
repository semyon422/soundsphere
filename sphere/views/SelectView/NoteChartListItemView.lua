local Class = require("aqua.util.Class")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local transform = require("aqua.graphics.transform")

local NoteChartListItemView = Class:new()

NoteChartListItemView.draw = function(self)
	local config = self.listView.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local y = (self.visualIndex - 1) * config.h / config.rows
	local item = self.item
	local noteChartDataEntry = item.noteChartDataEntry

	local prevItem = self.prevItem
	local nextItem = self.nextItem

	local fontName = spherefonts.get(config.name.fontFamily, config.name.fontSize)
	love.graphics.setFont(fontName)
	baseline_print(
		noteChartDataEntry.name,
		config.name.x,
		y + config.name.baseline,
		config.name.limit,
		1,
		config.name.align
	)

	if not prevItem or prevItem.noteChartDataEntry.creator ~= item.noteChartDataEntry.creator then
		local fontCreator = spherefonts.get(config.creator.fontFamily, config.creator.fontSize)
		love.graphics.setFont(fontCreator)
		baseline_print(
			noteChartDataEntry.creator,
			config.creator.x,
			y + config.creator.baseline,
			config.creator.limit,
			1,
			config.creator.align
		)
	end

	if not prevItem or prevItem.noteChartDataEntry.inputMode ~= item.noteChartDataEntry.inputMode then
		local fontInputMode = spherefonts.get(config.inputMode.fontFamily, config.inputMode.fontSize)
		love.graphics.setFont(fontInputMode)
		baseline_print(
			noteChartDataEntry.inputMode,
			config.inputMode.x,
			y + config.inputMode.baseline,
			config.inputMode.limit,
			1,
			config.inputMode.align
		)
	end

	local difficulty = noteChartDataEntry.noteCount / noteChartDataEntry.length / 3
	local format = "%.2f"
	if difficulty >= 10 then
		format = "%.1f"
	elseif difficulty >= 100 then
		format = "%d"
	elseif difficulty >= 1000 then
		format = "%s"
		difficulty = "???"
	end
	local fontDifficulty = spherefonts.get(config.difficulty.fontFamily, config.difficulty.fontSize)
	love.graphics.setFont(fontDifficulty)
	baseline_print(
		format:format(difficulty),
		config.difficulty.x,
		y + config.difficulty.baseline,
		config.difficulty.limit,
		1,
		config.difficulty.align
	)

	if item.tagged then
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

return NoteChartListItemView
