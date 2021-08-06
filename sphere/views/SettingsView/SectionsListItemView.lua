local viewspackage = (...):match("^(.-%.views%.)")

local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")

local ListItemView = require(viewspackage .. "ListItemView")

local SectionsListItemView = ListItemView:new()

SectionsListItemView.draw = function(self)
	local config = self.listView.config
	local cs = self.listView.cs
	local screen = config.screen
	local y = config.y + (self.visualIndex - 1) * config.h / config.rows

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(config.name.fontFamily, config.name.fontSize)
	love.graphics.setFont(font)
	baseline_print(
		self.item[1].section,
		cs:X((config.x + config.name.x) / screen.unit, true),
		cs:Y((y + config.name.baseline) / screen.unit, true),
		config.name.limit,
		cs.one / screen.unit,
		config.name.align
	)
end

return SectionsListItemView
