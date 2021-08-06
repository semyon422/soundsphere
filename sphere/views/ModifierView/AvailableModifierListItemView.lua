local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")

local Class = require("aqua.util.Class")

local AvailableModifierListItemView = Class:new()

AvailableModifierListItemView.draw = function(self)
	local config = self.listView.config
	local cs = self.listView.cs
	local screen = config.screen
	local y = config.y + (self.visualIndex - 1) * config.h / config.rows
	local item = self.item

	local prevItem = self.prevItem

	love.graphics.setColor(1, 1, 1, 1)
	if item.oneUse and item.added then
		love.graphics.setColor(config.name.addedColor)
	end

	local font = spherefonts.get(config.name.fontFamily, config.name.fontSize)
	love.graphics.setFont(font)
	baseline_print(
		item.name,
		cs:X((config.x + config.name.x) / screen.unit, true),
		cs:Y((y + config.name.baseline) / screen.unit, true),
		config.name.limit,
		cs.one / screen.unit,
		config.name.align
	)

	love.graphics.setColor(1, 1, 1, 1)
	if not prevItem or prevItem.oneUse ~= item.oneUse then
		local fontSection = spherefonts.get(config.section.fontFamily, config.section.fontSize)
		local text = "One use modifiers"
		if not item.oneUse then
			text = "Sequential modifiers"
		end
		love.graphics.setFont(fontSection)
		baseline_print(
			text,
			cs:X((config.x + config.section.x) / screen.unit, true),
			cs:Y((y + config.section.baseline) / screen.unit, true),
			config.section.limit,
			cs.one / screen.unit,
			config.section.align
		)
	end
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
