local Circle		= require("aqua.graphics.Circle")
local ImageFrame	= require("aqua.graphics.ImageFrame")
local Rectangle		= require("aqua.graphics.Rectangle")
local belong		= require("aqua.math").belong
local map			= require("aqua.math").map
local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local ImageButton	= require("aqua.ui.ImageButton")
local icons			= require("sphere.assets.icons")

local ListSwitcher = Class:new()

ListSwitcher.value = 1
ListSwitcher.maxValue = 1
	
ListSwitcher.image = love.graphics.newImage(icons.ic_arrow_forward_white_48dp)

ListSwitcher.construct = function(self)
	self.observable = Observable:new()
	
	self.drawable = ImageFrame:new({
		image = self.image,
		scale = 0.75,
		locate = "in",
		align = {
			x = "center",
			y = "center"
		}
	})
	
	self.button = ImageButton:new({
		drawable = self.drawable,
		interact = function() end
	})
end

ListSwitcher.reload = function(self)
	local drawable = self.drawable
	
	drawable.x = self.x
	drawable.y = self.y
	drawable.w = self.w
	drawable.h = self.h
	drawable.cs = self.cs
	
	self:setValue(self.value)
	self.drawable:reload()
	
	self.button:reload()
end

ListSwitcher.setValue = function(self, value) end

ListSwitcher.send = function(self, event)
	return self.observable:send(event)
end

ListSwitcher.receive = function(self, event)
	if event.name == "resize" then
		self:reload()
	elseif event.name == "mousepressed" then
		local mx = self.cs:x(event.args[1], true)
		local my = self.cs:y(event.args[2], true)
		if belong(mx, self.x, self.x + self.w) and belong(my, self.y, self.y + self.h) then
			self.value = self.value + 1
			if self.value > self.maxValue then
				self.value = 1
			end
			self:reload()
			
			self:send({
				name = "valueChanged",
				value = self.value
			})
		end
	end
end

ListSwitcher.draw = function(self)
	self.button:draw()
end

return ListSwitcher
