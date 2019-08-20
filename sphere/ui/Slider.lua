local Circle		= require("aqua.graphics.Circle")
local Rectangle		= require("aqua.graphics.Rectangle")
local belong		= require("aqua.math").belong
local map			= require("aqua.math").map
local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")

local Slider = Class:new()

Slider.value = 0

Slider.construct = function(self)
	self.observable = Observable:new()
	self.rectangle = Rectangle:new()
	self.circle = Circle:new()
end

Slider.reload = function(self)
	local rectangle = self.rectangle
	
	rectangle.x = self.x + (self.h - self.barHeight) / 2
	rectangle.y = self.y + (self.h - self.barHeight) / 2
	rectangle.w = self.w - (self.h - self.barHeight)
	rectangle.h = self.barHeight
	rectangle.rx = rectangle.h / 2
	rectangle.ry = rectangle.h / 2
	rectangle.mode = "fill"
	rectangle.color = self.rectangleColor
	rectangle.cs = self.cs
	
	self.rectangle:reload()
	
	local circle = self.circle
	
	circle.x = map(self.value, 0, 1, self.x + self.h / 2, self.x + self.w - self.h / 2)
	circle.y = self.y + self.h / 2
	circle.r = self.barHeight / 2
	circle.mode = "fill"
	circle.color = self.circleColor
	circle.cs = self.cs
	
	self.circle:reload()
end

Slider.setValue = function(self, value)
	self.value = value
	self:reload()
end

Slider.send = function(self, event)
	return self.observable:send(event)
end

Slider.receive = function(self, event)
	if event.name == "resize" then
		self:reload()
	elseif event.name == "mousepressed" then
		local mx = self.cs:x(event.args[1], true)
		local my = self.cs:y(event.args[2], true)
		if belong(mx, self.x, self.x + self.w) and belong(my, self.y, self.y + self.h) then
			self.pressed = true
			
			self:send({
				name = "pressed",
				value = self.value
			})
		end
	elseif event.name == "mousereleased" and self.pressed then
		self.pressed = false
		
		self:send({
			name = "released",
			value = self.value
		})
	elseif event.name == "mousemoved" and self.pressed then
		local mx = self.cs:x(event.args[1], true)
		local value = map(mx, self.x + self.h / 2, self.x + self.w - self.h / 2, 0, 1)
		self.value = math.min(math.max(value, 0), 1)
		self:reload()
		
		self:send({
			name = "valueChanged",
			value = self.value
		})
	end
end

Slider.draw = function(self)
	self.rectangle:draw()
	self.circle:draw()
end

return Slider
