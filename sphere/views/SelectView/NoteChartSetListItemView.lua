
local Class = require("aqua.util.Class")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local transform = require("aqua.graphics.transform")

local NoteChartSetListItemView = Class:new()

NoteChartSetListItemView.draw = function(self)
	local config = self.listView.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local y = (self.visualIndex - 1) * config.h / config.rows
	local item = self.item
	local noteChartDataEntry = item.noteChartDataEntries[1]

	love.graphics.setColor(1, 1, 1, 1)

	local fontArtist = spherefonts.get(config.artist.fontFamily, config.artist.fontSize)
	love.graphics.setFont(fontArtist)
	baseline_print(
		noteChartDataEntry.artist,
		config.artist.x,
		y + config.artist.baseline,
		config.artist.limit,
		1,
		config.artist.align
	)

	local fontTitle = spherefonts.get(config.title.fontFamily, config.title.fontSize)
	love.graphics.setFont(fontTitle)
	baseline_print(
		noteChartDataEntry.title,
		config.title.x,
		y + config.title.baseline,
		config.title.limit,
		1,
		config.title.align
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

return NoteChartSetListItemView
