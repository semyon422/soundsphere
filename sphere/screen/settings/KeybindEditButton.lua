local Circle		= require("aqua.graphics.Circle")
local ImageFrame	= require("aqua.graphics.ImageFrame")
local Rectangle		= require("aqua.graphics.Rectangle")
local belong		= require("aqua.math").belong
local map			= require("aqua.math").map
local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local ImageButton	= require("aqua.ui.ImageButton")
local icons			= require("sphere.assets.icons")

local KeybindEditButton = Class:new()

KeybindEditButton.value = ""

KeybindEditButton.editButtonImage = love.graphics.newImage(icons.ic_create_white_48dp)

KeybindEditButton.construct = function(self)
	self.observable = Observable:new()
	
	self.drawable = ImageFrame:new({
		image = self.editButtonImage,
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

KeybindEditButton.reload = function(self)
	local drawable = self.drawable
	
	drawable.x = self.x
	drawable.y = self.y
	drawable.w = self.w
	drawable.h = self.h
	drawable.cs = self.cs
	
	self.drawable:reload()
	
	self.button:reload()
end

KeybindEditButton.setValue = function(self, value)
	self.value = value
end

KeybindEditButton.send = function(self, event)
	return self.observable:send(event)
end

KeybindEditButton.receive = function(self, event)
	if event.name == "resize" then
		self:reload()
	elseif event.name == "mousepressed" then
		local mx = self.cs:x(event.args[1], true)
		local my = self.cs:y(event.args[2], true)
		if belong(mx, self.x, self.x + self.w) and belong(my, self.y, self.y + self.h) then
			self.active = true
		end
	elseif event.name == "keypressed" and self.active then
		self.active = false
		self.value = event.args[1]
		
		self:send({
			name = "valueChanged",
			value = self.value,
			type = "keyboard"
		})
	elseif event.name == "joystickpressed" and self.active then
		self.active = false
		self.value = tostring(event.args[2])
		
		self:send({
			name = "valueChanged",
			value = self.value,
			type = "joystick"
		})
	end
end

KeybindEditButton.draw = function(self)
	self.button:draw()
end

return KeybindEditButton
