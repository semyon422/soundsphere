local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")

local Class = require("aqua.util.Class")

local NoteSkinListItemView = Class:new()

NoteSkinListItemView.draw = function(self)
	local config = self.listView.config
	local cs = self.listView.cs
	local screen = config.screen
	local y = config.y + (self.visualIndex - 1) * config.h / config.rows
	local item = self.item

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(config.name.fontFamily, config.name.fontSize)
	love.graphics.setFont(font)
	baseline_print(
		item.name,
		cs:X((config.x + config.name.x) / screen.h, true),
		cs:Y((y + config.name.baseline) / screen.h, true),
		config.name.limit,
		cs.one / screen.h,
		config.name.align
	)

	if item == self.listView.state.selectedNoteSkin then
		love.graphics.circle(
			"line",
			cs:X((config.x + config.point.x) / screen.h, true),
			cs:Y((y + config.point.y) / screen.h, true),
			cs:X(config.point.r / screen.h)
		)
		love.graphics.circle(
			"fill",
			cs:X((config.x + config.point.x) / screen.h, true),
			cs:Y((y + config.point.y) / screen.h, true),
			cs:X(config.point.r / screen.h)
		)
	end
end

NoteSkinListItemView.receive = function(self, event)
	if event.name ~= "mousepressed" then
		return
	end

	local mx, my = love.mouse.getPosition()
	local x, y, w, h = self.listView:getItemPosition(self.itemIndex)

	if (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		local button = event.args[3]
		if button == 1 then
			self.listView.navigator:setNoteSkin(self.itemIndex)
		end
	end
end

return NoteSkinListItemView
