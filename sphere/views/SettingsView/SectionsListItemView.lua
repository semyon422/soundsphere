local viewspackage = (...):match("^(.-%.views%.)")

local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local transform = require("aqua.graphics.transform")

local ListItemView = require(viewspackage .. "ListItemView")

local SectionsListItemView = ListItemView:new()

SectionsListItemView.draw = function(self)
	local config = self.listView.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local y = (self.visualIndex - 1) * config.h / config.rows

	local font = spherefonts.get(config.name.fontFamily, config.name.fontSize)
	love.graphics.setFont(font)
	baseline_print(
		self.item[1].section,
		config.name.x,
		y + config.name.baseline,
		config.name.limit,
		1,
		config.name.align
	)
end

return SectionsListItemView
