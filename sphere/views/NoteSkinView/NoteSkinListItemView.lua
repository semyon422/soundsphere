local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local transform = require("aqua.graphics.transform")

local Class = require("aqua.util.Class")

local NoteSkinListItemView = Class:new()

NoteSkinListItemView.draw = function(self)
	local config = self.listView.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local y = (self.visualIndex - 1) * config.h / config.rows
	local item = self.item

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(config.name.fontFamily, config.name.fontSize)
	love.graphics.setFont(font)
	baseline_print(
		item.name,
		config.name.x,
		y + config.name.baseline,
		config.name.limit,
		1,
		config.name.align
	)

	if item == self.listView.state.selectedNoteSkin then
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

NoteSkinListItemView.receive = function(self, event)
	if event.name ~= "mousepressed" then
		return
	end

	local config = self.listView.config

	local x, y, w, h = self.listView:getItemPosition(self.itemIndex)
	local tf = transform(config.transform)
	local mx, my = tf:inverseTransformPoint(love.mouse.getPosition())

	if (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		local button = event.args[3]
		if button == 1 then
			self.listView.navigator:setNoteSkin(self.itemIndex)
		end
	end
end

return NoteSkinListItemView
