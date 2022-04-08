local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local transform = require("aqua.graphics.transform")
local inside = require("aqua.util.inside")
local rtime = require("aqua.util.rtime")
local time_ago_in_words = require("aqua.util").time_ago_in_words

local Class = require("aqua.util.Class")

local ListItemView = Class:new()

ListItemView.draw = function(self)
	local config = self.listView.config

	local tf = transform(config.transform):translate(config.x, config.y)
	love.graphics.replaceTransform(tf)
	tf:release()

	love.graphics.setColor(1, 1, 1, 1)

	if config.elements then
		self:drawElements(config.elements)
	end
end

ListItemView.drawElements = function(self, elements)
	local item = self.item

	local prevItem = self.prevItem
	local nextItem = self.nextItem

	for _, element in ipairs(elements) do
		local value = element.value or inside(item, element.key)
		if not element.onNew or not prevItem or (element.value or inside(prevItem, element.key)) ~= value then
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

	if type(value) == "function" then
		value = value()
	end
	if valueConfig.format then
		local format = valueConfig.format
		if type(format) == "string" then
			value = format:format(value)
		elseif type(format) == "function" then
			value = format(value)
		end
	elseif valueConfig.time then
		value = rtime(tonumber(value) or 0)
	elseif valueConfig.ago then
		value = tonumber(value) or 0
		value = value ~= 0 and time_ago_in_words(value, valueConfig.parts, valueConfig.suffix) or "never"
	end

	local font = spherefonts.get(valueConfig.font)
	love.graphics.setFont(font)
	baseline_print(
		tostring(value),
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

	local tf = transform(config.transform):translate(config.x, config.y)
	local mx, my = tf:inverseTransformPoint(event[1], event[2])
	tf:release()

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
