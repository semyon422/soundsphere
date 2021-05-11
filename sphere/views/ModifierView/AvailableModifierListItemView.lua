local spherefonts		= require("sphere.assets.fonts")

local Class = require("aqua.util.Class")

local AvailableModifierListItemView = Class:new()

AvailableModifierListItemView.draw = function(self)
	local config = self.listView.config
	local cs = self.listView.cs
	local screen = config.screen
	local y = config.y + (self.visualIndex - 1) * config.h / config.rows
	local item = self.item

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(config.name.fontFamily, config.name.fontSize)
	love.graphics.setFont(font)
	love.graphics.printf(
		item.name,
		cs:X((config.x + config.name.x) / screen.h, true),
		cs:Y((y + config.name.y) / screen.h, true),
		config.name.w,
		config.name.align,
		0,
		cs.one / screen.h,
		cs.one / screen.h
	)
end

AvailableModifierListItemView.receive = function(self, event)
	local x, y, w, h = self.listView:getItemPosition(self.itemIndex)
	local mx, my = love.mouse.getPosition()

	if event.name == "mousepressed" and (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		local button = event.args[3]
		if button == 1 then
			self.listView.navigator:addModifier(self.itemIndex)
		end
	end
end

return AvailableModifierListItemView
