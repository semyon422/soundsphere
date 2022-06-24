local just = require("just")
local Class = require("aqua.util.Class")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local transform = require("aqua.graphics.transform")

local ScreenMenuItemView = Class:new()

ScreenMenuItemView.draw = function(self)
	local listView = self.listView
	local item = self.item

	local tf = transform(listView.transform):translate(listView.x, listView.y)
	love.graphics.replaceTransform(tf)

	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())

	local x = (self.column - 1) * listView.w / listView.columns
	local y = (self.row - 1) * listView.h / listView.rows
	local w = listView.w / listView.columns
	local h = listView.h / listView.rows

	local over = x <= mx and mx <= x + w and y <= my and my <= y + h

	local changed, active, hovered = just.button_behavior(item, over)
	if changed then
		listView.navigator:call(item.method, item.value)
	end

	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", x, y, w, h)
	end

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(listView.text.font)
	love.graphics.setFont(font)
	baseline_print(
		item.displayName,
		(self.column - 1) * listView.w / listView.columns + listView.text.x,
		(self.row - 1) * listView.h / listView.rows + listView.text.baseline,
		listView.text.limit,
		1,
		listView.text.align
	)
end

return ScreenMenuItemView
