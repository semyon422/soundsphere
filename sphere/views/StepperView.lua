local Class			= require("aqua.util.Class")
local icons			= require("sphere.assets.icons")

local StepperView = Class:new()

StepperView.construct = function(self)
	self.leftImage = love.graphics.newImage(icons.ic_keyboard_arrow_left_white_48dp)
	self.rightImage = love.graphics.newImage(icons.ic_keyboard_arrow_right_white_48dp)
end

StepperView.x = 0
StepperView.y = 0
StepperView.w = 0
StepperView.h = 0
StepperView.value = 1
StepperView.count = 1

StepperView.setPosition = function(self, x, y, w, h)
	self.x, self.y, self.w, self.h = x, y, w, h
end

StepperView.setValue = function(self, value)
	self.value = value
end

StepperView.setCount = function(self, count)
	self.count = count
end

StepperView.draw = function(self)
	local x, y, w, h = self.x, self.y, self.w, self.h

	local leftImage = self.leftImage
	local rightImage = self.rightImage

	love.graphics.setColor(1, 1, 1)

    if self.value > 1 then
        love.graphics.draw(
            leftImage,
            x,
            y,
            0,
            h / leftImage:getWidth(),
            h / leftImage:getHeight()
        )
    end
    if self.value < self.count then
        love.graphics.draw(
            rightImage,
            x + w - h,
            y,
            0,
            h / rightImage:getWidth(),
            h / rightImage:getHeight()
        )
    end
end

return StepperView
