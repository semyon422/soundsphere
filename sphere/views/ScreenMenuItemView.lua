local just = require("just")
local Class = require("aqua.util.Class")
local frame_print = require("aqua.graphics.frame_print")

local ScreenMenuItemView = Class:new()

ScreenMenuItemView.isOver = function(self, w, h)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	return 0 <= mx and mx <= 0 + w and 0 <= my and my <= 0 + h
end

ScreenMenuItemView.draw = function(self, text, w, h, method, ...)
	local listView = self.listView

	local changed, active, hovered = just.button_behavior(self.item, self:isOver(w, h))
	if changed then
		listView.navigator:call(method, ...)
	end

	self:_draw(text, w, h, active, hovered)
end

ScreenMenuItemView._draw = function(self, text, w, h, active, hovered)
	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, w, h)
	end
	love.graphics.setColor(1, 1, 1, 1)
	frame_print(text, 0, 0, w, h, 1, "center", "center")
end

return ScreenMenuItemView
