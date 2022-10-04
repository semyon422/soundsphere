local Class = require("Class")

local SwitchView = Class:new()

SwitchView.isOver = function(self, w, h)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	return 0 <= mx and mx <= w and 0 <= my and my <= h
end

SwitchView.draw = function(self, w, h, value)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(1)

	if value then
		love.graphics.circle("fill", w - h / 2, h / 2, h / 4)
	end
	love.graphics.circle("line", w - h / 2, h / 2, h / 4)
end

return SwitchView
