local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local transform = require("aqua.graphics.transform")
local inside = require("aqua.util.inside")

local Class = require("aqua.util.Class")

local ListItemView = Class:new()

ListItemView.draw = function(self)
	local config = self.listView.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	self:drawElements()
end

ListItemView.drawElements = function(self)
	local config = self.listView.config

	local item = self.item

	local prevItem = self.prevItem
	local nextItem = self.nextItem

	for _, element in ipairs(config.elements) do
		local value = inside(item, element.field)
		if not element.onNew or not prevItem or inside(prevItem, element.field) ~= value then
			if element.type == "text" then
				self:drawValue(element, value)
			elseif element.type == "circle" then
				self:drawCircle(element, value)
			end
		end
	end
end

ListItemView.drawValue = function(self, valueConfig, value)
	local config = self.listView.config

	local format = valueConfig.format
	if type(format) == "string" then
		value = format:format(value)
	end

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

ListItemView.drawCircle = function(self, valueConfig, value)
	if not value then return end

	local config = self.listView.config

	local y = (self.visualIndex - 1) * config.h / config.rows
	love.graphics.circle(
		"line",
		valueConfig.x,
		y + valueConfig.y,
		valueConfig.r
	)
	love.graphics.circle(
		"fill",
		valueConfig.x,
		y + valueConfig.y,
		valueConfig.r
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
