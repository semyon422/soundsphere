
local Class			= require("aqua.util.Class")
local belong		= require("aqua.math").belong

local Stepper = Class:new()

Stepper.x = 0
Stepper.y = 0
Stepper.w = 0
Stepper.h = 0
Stepper.value = 1
Stepper.count = 1
Stepper.pressed = false

Stepper.setPosition = function(self, x, y, w, h)
	self.x, self.y, self.w, self.h = x, y, w, h
end

Stepper.setTransform = function(self, transform)
	self.transform = transform
end

Stepper.setValue = function(self, value)
	self.value = value
end

Stepper.setCount = function(self, count)
	self.count = count
end

Stepper.receive = function(self, event)
	if event.name == "mousepressed" then
        local button = event.args[3]
        if button ~= 1 then
            return
        end
		local mx, my = self.transform:inverseTransformPoint(event.args[1], event.args[2])
		local x, y, w, h = self.x, self.y, self.w, self.h
		if belong(mx, x, x + h) and belong(my, y, y + h) then
			self.value = math.max(self.value - 1, 1)
			self.valueUpdated = true
        elseif belong(mx, x + w - h, x + w) and belong(my, y, y + h) then
			self.value = math.min(self.value + 1, self.count)
			self.valueUpdated = true
		end
	end
end

return Stepper
