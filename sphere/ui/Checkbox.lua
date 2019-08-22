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

Checkbox.value = 0
	
Checkbox.settingsImage = love.graphics.newImage(icons.ic_settings_white_48dp)

Checkbox.construct = function(self)
	self.observable = Observable:new()
	
	self.settingsDrawable = ImageFrame:new({
		image = self.settingsImage,
		scale = 0.66,
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
	settingsDrawable.h = self.р
	settingsDrawable.cs = self.cs
	
	self.settingsDrawable:reload()
	
	self.settingsButton:reload()
end

Checkbox.setValue = function(self, value)
	self.value = value
	self:reload()
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

Checkbox.draw = function(self)
	self.settingsButton:draw()
end

return Checkbox
