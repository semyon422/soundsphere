local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local inside = require("aqua.util.inside")
local rtime = require("aqua.util.rtime")
local time_ago_in_words = require("aqua.util").time_ago_in_words

local Class = require("aqua.util.Class")

local ListItemView = Class:new()

ListItemView.isOver = function(self, w, h)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	return 0 <= mx and mx <= w and 0 <= my and my <= h
end

ListItemView.draw = function(self)
	local listView = self.listView

	if listView.elements then
		self:drawElements(listView.elements)
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
	local listView = self.listView

	if type(value) == "function" then
		value = value(listView, self.item)
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

	love.graphics.setFont(spherefonts.get(unpack(valueConfig.font)))
	baseline_print(
		tostring(value),
		valueConfig.x,
		valueConfig.baseline,
		valueConfig.limit,
		1,
		valueConfig.align
	)
end

ListItemView.drawCircle = function(self, valueConfig, value)
	if not value then return end

	local t = valueConfig.mode
	if not t or t == "line" or t == "both" then
		love.graphics.circle(
			"line",
			valueConfig.x,
			valueConfig.y,
			valueConfig.r
		)
	end
	if not t or t == "fill" or t == "both" then
		love.graphics.circle(
			"fill",
			valueConfig.x,
			valueConfig.y,
			valueConfig.r
		)
	end
end

return ListItemView
