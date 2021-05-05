
local Class = require("aqua.util.Class")
local spherefonts		= require("sphere.assets.fonts")

local NoteChartSetListItemView = Class:new()

NoteChartSetListItemView.draw = function(self)
	local config = self.listView.config
	local cs = self.listView.cs
	local screen = config.screen
	local y = config.y + (self.index - 1) * config.h / config.rows
	local item = self.item
	local noteChartDataEntry = item.noteChartDataEntries[1]

	love.graphics.setColor(1, 1, 1, 1)

	local fontArtist = spherefonts.get(config.artist.fontFamily, config.artist.fontSize)
	love.graphics.setFont(fontArtist)
	love.graphics.printf(
		noteChartDataEntry.artist,
		cs:X((config.x + config.artist.x) / screen.h, true),
		cs:Y((y + config.artist.y) / screen.h, true),
		config.artist.w,
		config.artist.align,
		0,
		cs.one / screen.h,
		cs.one / screen.h
	)

	local fontTitle = spherefonts.get(config.title.fontFamily, config.title.fontSize)
	love.graphics.setFont(fontTitle)
	love.graphics.printf(
		noteChartDataEntry.title,
		cs:X((config.x + config.title.x) / screen.h, true),
		cs:Y((y + config.title.y) / screen.h, true),
		-- config.title.w,
		math.huge,
		config.title.align,
		0,
		cs.one / screen.h,
		cs.one / screen.h
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

return NoteChartSetListItemView
