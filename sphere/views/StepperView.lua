local Class			= require("aqua.util.Class")

local StepperView = Class:new()

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

	love.graphics.setColor(1, 1, 1, 1)

	local ty = y + h / 3
	local by = y + 2 * h / 3
	local my = y + h / 2

	local rx1 = x + h / 2
	local lx1 = rx1 - h / 6

	local lx2 = rx1 + w - h
	local rx2 = lx2 + h / 6

    if self.value > 1 then
		love.graphics.polygon(
			"fill",
			rx1, ty,
			lx1, my,
			rx1, by
		)
    end
    if self.value < self.count then
		love.graphics.polygon(
			"fill",
			lx2, ty,
			rx2, my,
			lx2, by
		)
    end
end

return StepperView
