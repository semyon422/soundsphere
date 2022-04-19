local Class = require("aqua.util.Class")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local transform = require("aqua.graphics.transform")

local ScreenMenuItemView = Class:new()

ScreenMenuItemView.draw = function(self)
	local config = self.listView.config

	local tf = transform(config.transform):translate(config.x, config.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)

	local item = self.item

	local font = spherefonts.get(config.text.font)
	love.graphics.setFont(font)
	baseline_print(
		item.displayName,
		(self.column - 1) * config.w / config.columns + config.text.x,
		(self.row - 1) * config.h / config.rows + config.text.baseline,
		config.text.limit,
		1,
		config.text.align
	)
end

ScreenMenuItemView.receive = function(self, event)
	local listView = self.listView
	local config = listView.config

	if event.name == "mousepressed" then
		local tf = transform(config.transform)
		local mx, my = tf:inverseTransformPoint(event[1], event[2])

		local button = event[3]

		local x = config.x + (self.column - 1) * config.w / config.columns
		local y = config.y + (self.row - 1) * config.h / config.rows

		local w = config.w / config.columns
		local h = config.h / config.rows

		if mx >= x and mx < x + w and my >= y and my < y + h and button == 1 then
			listView.navigator:call(self.item.method, self.item.value)
		end
	end
end

return ScreenMenuItemView
