local Circle		= require("aqua.graphics.Circle")
local ImageFrame	= require("aqua.graphics.ImageFrame")
local Rectangle		= require("aqua.graphics.Rectangle")
local belong		= require("aqua.math").belong
local map			= require("aqua.math").map
local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local ImageButton	= require("aqua.ui.ImageButton")
local icons			= require("sphere.assets.icons")

local Checkbox = Class:new()

Checkbox.value = false
	
Checkbox.checkboxOffImage = love.graphics.newImage(icons.ic_check_box_outline_blank_white_24dp)
Checkbox.checkboxOnImage = love.graphics.newImage(icons.ic_check_box_white_24dp)

Checkbox.construct = function(self)
	self.observable = Observable:new()
	
	self.settingsDrawable = ImageFrame:new({
		image = self.checkboxOffImage,
		scale = 0.75,
		locate = "in",
		align = {
			x = "center",
			y = "center"
		}
	})
	
	self.settingsButton = ImageButton:new({
		drawable = self.settingsDrawable,
		interact = function()
			return ScreenManager:set(require("sphere.screen.settings.SettingsScreen"))
		end
	})
end

Checkbox.reload = function(self)
	local settingsDrawable = self.settingsDrawable
	
	settingsDrawable.x = self.x
	settingsDrawable.y = self.y
	settingsDrawable.w = self.w
	settingsDrawable.h = self.h
	settingsDrawable.cs = self.cs
	
	self:setValue(self.value)
	self.settingsDrawable:reload()
	
	self.settingsButton:reload()
end

Checkbox.setValue = function(self, value)
	self.value = value
	if self.value then
		self.settingsDrawable.image = self.checkboxOnImage
	else
		self.settingsDrawable.image = self.checkboxOffImage
	end
end

Checkbox.send = function(self, event)
	return self.observable:send(event)
end

Checkbox.receive = function(self, event)
	if event.name == "resize" then
		self:reload()
	elseif event.name == "mousepressed" then
		local mx = self.cs:x(event.args[1], true)
		local my = self.cs:y(event.args[2], true)
		if belong(mx, self.x, self.x + self.w) and belong(my, self.y, self.y + self.h) then
			self.value = not self.value
			self:reload()
			
			self:send({
				name = "valueChanged",
				value = self.value
			})
		end
	end
end

Checkbox.draw = function(self)
	self.settingsButton:draw()
end

return Checkbox
