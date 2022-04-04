local Class			= require("aqua.util.Class")

local SwitchView = Class:new()

SwitchView.x = 0
SwitchView.y = 0
SwitchView.w = 0
SwitchView.h = 0
SwitchView.value = false

SwitchView.setPosition = function(self, x, y, w, h)
	self.x, self.y, self.w, self.h = x, y, w, h
end

SwitchView.setValue = function(self, value)
	self.value = value
end

SwitchView.draw = function(self)
	local x, y, w, h = self.x, self.y, self.w, self.h

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(1)

	if self.value then
		love.graphics.circle(
			"fill",
			x + w - h / 2,
			y + h / 2,
			h / 4
		)
	end
	love.graphics.circle(
		"line",
		x + w - h / 2,
		y + h / 2,
		h / 4
	)
end

return SwitchView
