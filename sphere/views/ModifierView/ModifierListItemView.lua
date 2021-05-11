local viewspackage = (...):match("^(.-%.views%.)")
local spherefonts		= require("sphere.assets.fonts")

local ListItemView = require(viewspackage .. "ListItemView")

local ModifierListItemView = ListItemView:new()

ModifierListItemView.draw = function(self)
	local config = self.listView.config
	local cs = self.listView.cs
	local screen = config.screen
	local modifierConfig = self.item
	local y = config.y + (self.visualIndex - 1) * config.h / config.rows

	local font = spherefonts.get(config.name.fontFamily, config.name.fontSize)
	love.graphics.setFont(font)
	love.graphics.printf(
		modifierConfig.name,
		cs:X((config.x + config.name.x) / screen.h, true),
		cs:Y((y + config.name.y) / screen.h, true),
		config.name.w,
		config.name.align,
		0,
		cs.one / screen.h,
		cs.one / screen.h
	)
end

ModifierListItemView.drawValue = function(self, value)
	local config = self.listView.config
	local cs = self.listView.cs
	local screen = config.screen
	local modifierConfig = self.item
	local y = config.y + (self.visualIndex - 1) * config.h / config.rows

	local font = spherefonts.get(value.fontFamily, value.fontSize)
	love.graphics.setFont(font)
	love.graphics.printf(
		modifierConfig.value,
		cs:X((config.x + value.x) / screen.h, true),
		cs:Y((y + value.y) / screen.h, true),
		value.w,
		value.align,
		0,
		cs.one / screen.h,
		cs.one / screen.h
	)
end

ModifierListItemView.receive = function(self, event)
	local listView = self.listView

	local x, y, w, h = self.listView:getItemPosition(self.itemIndex)
	local mx, my = love.mouse.getPosition()

	if event.name == "mousepressed" and (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		listView.activeItem = self.itemIndex
		local button = event.args[3]
		if button == 2 then
			self.listView.navigator:removeModifier(self.itemIndex)
		end
	end
	if event.name == "mousereleased" then
		listView.activeItem = listView.selectedItem
	end
end

return ModifierListItemView
