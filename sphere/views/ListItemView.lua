local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")

local Class = require("aqua.util.Class")

local ListItemView = Class:new()

ListItemView.drawValue = function(self, valueConfig, value)
	local config = self.listView.config
	local cs = self.listView.cs
	local screen = config.screen
	local y = config.y + (self.visualIndex - 1) * config.h / config.rows

	local font = spherefonts.get(valueConfig.fontFamily, valueConfig.fontSize)
	love.graphics.setFont(font)
	love.graphics.setColor(1, 1, 1, 1)
	baseline_print(
		value,
		cs:X((config.x + valueConfig.x) / screen.h, true),
		cs:Y((y + valueConfig.baseline) / screen.h, true),
		valueConfig.limit,
		cs.one / screen.h,
		valueConfig.align
	)
end

ListItemView.receive = function(self, event)
	local listView = self.listView

	local x, y, w, h = self.listView:getItemPosition(self.itemIndex)
	local mx, my = love.mouse.getPosition()

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
