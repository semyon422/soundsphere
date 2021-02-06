local map			= require("aqua.math").map
local Class			= require("aqua.util.Class")

local SliderView = Class:new()

SliderView.x = 0
SliderView.y = 0
SliderView.w = 0
SliderView.h = 0
SliderView.value = 0

SliderView.setPosition = function(self, x, y, w, h)
	self.x, self.y, self.w, self.h = x, y, w, h
end

SliderView.setValue = function(self, value)
	self.value = value
end

SliderView.draw = function(self)
    local x, y, w, h = self.x, self.y, self.w, self.h

    local barHeight = h / 4

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle(
        "fill",
        x + (h - barHeight) / 2,
        y + (h - barHeight) / 2,
        w - (h - barHeight),
        barHeight,
        barHeight / 2,
        barHeight / 2
    )

    love.graphics.setColor(1, 1, 1)
    love.graphics.circle(
        "fill",
        map(self.value, 0, 1, x + h / 2, x + w - h / 2),
        y + h / 2,
        barHeight / 1.5
    )
end

return SliderView
