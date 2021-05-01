
local Class = require("aqua.util.Class")
local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local NoteChartSetListItemView = Class:new()

NoteChartSetListItemView.draw = function(self)
	local config = self.listView.config
	local cs = self.listView.cs
	local screen = config.screen
	local y = config.y + (self.index - 1) * config.h / config.rows
	local noteChartDataEntry = self.item.noteChartDataEntries[1]

	love.graphics.setColor(1, 1, 1, 1)

	local fontArtist = aquafonts.getFont(spherefonts.NotoSansRegular, config.artist.fontSize)
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

	local fontTitle = aquafonts.getFont(spherefonts.NotoSansRegular, config.title.fontSize)
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
end

return NoteChartSetListItemView
