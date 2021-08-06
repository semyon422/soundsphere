local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local transform = require("aqua.graphics.transform")

local Class = require("aqua.util.Class")

local ListItemView = Class:new()

ListItemView.drawValue = function(self, valueConfig, value)
	local config = self.listView.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(valueConfig.fontFamily, valueConfig.fontSize)
	love.graphics.setFont(font)
	baseline_print(
		value,
		valueConfig.x,
		(self.visualIndex - 1) * config.h / config.rows + valueConfig.baseline,
		valueConfig.limit,
		1,
		valueConfig.align
	)
end

ListItemView.receive = function(self, event)
	local listView = self.listView
	local config = self.listView.config

	local x, y, w, h = self.listView:getItemPosition(self.itemIndex)

	local tf = transform(config.transform)
	local mx, my = tf:inverseTransformPoint(event.args[1], event.args[2])

	if event.name == "mousepressed" and (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		listView.activeItem = self.itemIndex
		self:mousepressed(event)
	end
	if event.name == "mousereleased" then
		self:mousereleased(event)
		listView.activeItem = listView.selectedItem
	end
end

ListItemView.mousepressed = function(self, event) end
ListItemView.mousereleased = function(self, event) end

return ListItemView
