
local Class			= require("aqua.util.Class")
local belong		= require("aqua.math").belong
local map			= require("aqua.math").map

local Slider = Class:new()

Slider.x = 0
Slider.y = 0
Slider.w = 0
Slider.h = 0
Slider.value = 0
Slider.pressed = false

Slider.setPosition = function(self, x, y, w, h)
	self.x, self.y, self.w, self.h = x, y, w, h
end

Slider.setTransform = function(self, transform)
	self.transform = transform
end

Slider.setValue = function(self, value)
	self.value = value
end

Slider.updateValueMouse = function(self, mx)
	local value = map(mx, self.x + self.h / 2, self.x + self.w - self.h / 2, 0, 1)
	self.value = math.min(math.max(value, 0), 1)
	self.valueUpdated = true
end

Slider.receive = function(self, event)
	if event.name == "mousepressed" then
		local mx, my = self.transform:inverseTransformPoint(event[1], event[2])
		if belong(mx, self.x, self.x + self.w) and belong(my, self.y, self.y + self.h) then
			self.pressed = true
			self:updateValueMouse(mx)
		end
	elseif event.name == "mousereleased" and self.pressed then
		self.pressed = false
	elseif event.name == "mousemoved" and self.pressed then
		local mx, my = self.transform:inverseTransformPoint(event[1], event[2])
		self:updateValueMouse(mx)
	end
end

return Slider
