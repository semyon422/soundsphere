local Class = require("aqua.util.Class")
local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")
local belong		= require("aqua.math").belong

local HorizontalScreenMenuItemView = Class:new()

HorizontalScreenMenuItemView.draw = function(self)
	local config = self.listView.config
	local cs = self.listView.cs
	local screen = config.screen
	local x = config.x + (self.index - 1) * config.w / config.columns
	local item = self.item

	love.graphics.setColor(1, 1, 1, 1)

	local font = aquafonts.getFont(spherefonts.NotoSansRegular, config.text.fontSize)
	love.graphics.setFont(font)
	love.graphics.printf(
		item.displayName,
		cs:X((x + config.text.x) / screen.h, true),
		cs:Y((config.y + config.text.y) / screen.h, true),
		config.text.w,
		config.text.align,
		0,
		cs.one / screen.h,
		cs.one / screen.h
	)
end

HorizontalScreenMenuItemView.receive = function(self, event)
	local listView = self.listView
	local config = listView.config
	local cs = listView.cs

	if event.name == "mousepressed" then
		local mx, my, button = event.args[1], event.args[2], event.args[3]

		local x = config.x + (self.index - 1) * config.w / config.columns
		x = cs:X(x / config.screen.h, true)

		local w = config.w / config.columns
		w = cs:X(w / config.screen.h)

		local y = cs:Y(config.y / config.screen.h, true)
		local h = cs:Y(config.h / config.screen.h)
		if mx >= x and mx < x + w and my >= y and my < y + h and button == 1 then
			listView.navigator:changeScreen(self.item.name)
		end
	end
end

return HorizontalScreenMenuItemView
