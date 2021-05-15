local viewspackage = (...):match("^(.-%.views%.)")

local spherefonts		= require("sphere.assets.fonts")

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
	love.graphics.printf(
		self.item[1].section,
		cs:X((config.x + config.name.x) / screen.h, true),
		cs:Y((y + config.name.y) / screen.h, true),
		config.name.w,
		config.name.align,
		0,
		cs.one / screen.h,
		cs.one / screen.h
	)
end

return SectionsListItemView
