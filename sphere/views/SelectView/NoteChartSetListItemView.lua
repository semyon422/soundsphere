
local Class = require("aqua.util.Class")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")

local NoteChartSetListItemView = Class:new()

NoteChartSetListItemView.draw = function(self)
	local config = self.listView.config
	local cs = self.listView.cs
	local screen = config.screen
	local y = config.y + (self.visualIndex - 1) * config.h / config.rows
	local item = self.item
	local noteChartDataEntry = item.noteChartDataEntries[1]

	love.graphics.setColor(1, 1, 1, 1)

	local fontArtist = spherefonts.get(config.artist.fontFamily, config.artist.fontSize)
	love.graphics.setFont(fontArtist)
	baseline_print(
		noteChartDataEntry.artist,
		cs:X((config.x + config.artist.x) / screen.unit, true),
		cs:Y((y + config.artist.baseline) / screen.unit, true),
		config.artist.limit,
		cs.one / screen.unit,
		config.artist.align
	)

	local fontTitle = spherefonts.get(config.title.fontFamily, config.title.fontSize)
	love.graphics.setFont(fontTitle)
	baseline_print(
		noteChartDataEntry.title,
		cs:X((config.x + config.title.x) / screen.unit, true),
		cs:Y((y + config.title.baseline) / screen.unit, true),
		config.title.limit,
		cs.one / screen.unit,
		config.title.align
	)

	if item.tagged then
		love.graphics.circle(
			"line",
			cs:X((config.x + config.point.x) / screen.unit, true),
			cs:Y((y + config.point.y) / screen.unit, true),
			cs:X(config.point.r / screen.unit)
		)
		love.graphics.circle(
			"fill",
			cs:X((config.x + config.point.x) / screen.unit, true),
			cs:Y((y + config.point.y) / screen.unit, true),
			cs:X(config.point.r / screen.unit)
		)
	end
end

return NoteChartSetListItemView
