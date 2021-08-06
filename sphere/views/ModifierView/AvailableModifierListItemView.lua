local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local transform = require("aqua.graphics.transform")

local Class = require("aqua.util.Class")

local AvailableModifierListItemView = Class:new()

AvailableModifierListItemView.draw = function(self)
	local config = self.listView.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local y = (self.visualIndex - 1) * config.h / config.rows
	local item = self.item

	local prevItem = self.prevItem

	if item.oneUse and item.added then
		love.graphics.setColor(config.name.addedColor)
	end

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
			config.section.x,
			y + config.section.baseline,
			config.section.limit,
			1,
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
