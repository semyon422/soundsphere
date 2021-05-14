local Class = require("aqua.util.Class")
local spherefonts		= require("sphere.assets.fonts")

local NoteChartListItemView = Class:new()

NoteChartListItemView.draw = function(self)
	local config = self.listView.config
	local cs = self.listView.cs
	local screen = config.screen
	local y = config.y + (self.visualIndex - 1) * config.h / config.rows
	local item = self.item
	local noteChartDataEntry = item.noteChartDataEntry

	local prevItem = self.prevItem
	local nextItem = self.nextItem

	local scale = cs.one / screen.h

	local fontName = spherefonts.get(config.name.fontFamily, config.name.fontSize)
	love.graphics.setFont(fontName)
	love.graphics.printf(
		noteChartDataEntry.name,
		cs:X((config.x + config.name.x) / screen.h, true),
		cs:Y((y + config.name.y) / screen.h, true),
		config.name.w,
		config.name.align,
		0,
		scale,
		scale
	)

	if not prevItem or prevItem.noteChartDataEntry.creator ~= item.noteChartDataEntry.creator then
		local fontCreator = spherefonts.get(config.creator.fontFamily, config.creator.fontSize)
		love.graphics.setFont(fontCreator)
		love.graphics.printf(
			noteChartDataEntry.creator,
			cs:X((config.x + config.creator.x) / screen.h, true),
			cs:Y((y + config.creator.y) / screen.h, true),
			config.creator.w,
			config.creator.align,
			0,
			scale,
			scale
		)
	end

	if not prevItem or prevItem.noteChartDataEntry.inputMode ~= item.noteChartDataEntry.inputMode then
		local fontInputMode = spherefonts.get(config.inputMode.fontFamily, config.inputMode.fontSize)
		love.graphics.setFont(fontInputMode)
		love.graphics.printf(
			noteChartDataEntry.inputMode,
			cs:X((config.x + config.inputMode.x) / screen.h, true),
			cs:Y((y + config.inputMode.y) / screen.h, true),
			config.inputMode.w,
			config.inputMode.align,
			0,
			scale,
			scale
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
	love.graphics.printf(
		format:format(difficulty),
		cs:X((config.x + config.difficulty.x) / screen.h, true),
		cs:Y((y + config.difficulty.y) / screen.h, true),
		config.difficulty.w,
		config.difficulty.align,
		0,
		scale,
		scale
	)

	if item.tagged then
		love.graphics.circle(
			"line",
			cs:X((config.x + config.point.x) / screen.h, true),
			cs:Y((y + config.point.y) / screen.h, true),
			cs:X(config.point.r / screen.h, true)
		)
		love.graphics.circle(
			"fill",
			cs:X((config.x + config.point.x) / screen.h, true),
			cs:Y((y + config.point.y) / screen.h, true),
			cs:X(config.point.r / screen.h, true)
		)
	end
end

return NoteChartListItemView
