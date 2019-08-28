local Circle		= require("aqua.graphics.Circle")
local ImageFrame	= require("aqua.graphics.ImageFrame")
local Rectangle		= require("aqua.graphics.Rectangle")
local belong		= require("aqua.math").belong
local map			= require("aqua.math").map
local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local ImageButton	= require("aqua.ui.ImageButton")
local icons			= require("sphere.assets.icons")

local IconButton = Class:new()

IconButton.sender = "IconButton"
	
IconButton.image = love.graphics.newImage(icons.ic_add_white_48dp)

IconButton.construct = function(self)
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

IconButton.reload = function(self)
	local drawable = self.drawable
	
	drawable.x = self.x
	drawable.y = self.y
	drawable.w = self.w
	drawable.h = self.h
	drawable.cs = self.cs
	
	self.drawable:reload()
	
	self.button:reload()
end

IconButton.send = function(self, event)
	return self.observable:send(event)
end

IconButton.receive = function(self, event)
	if event.name == "resize" then
		self:reload()
	elseif event.name == "mousepressed" then
		local mx = self.cs:x(event.args[1], true)
		local my = self.cs:y(event.args[2], true)
		if belong(mx, self.x, self.x + self.w) and belong(my, self.y, self.y + self.h) then
			self:send({
				name = "ButtonPressed",
				sender = self.sender
			})
		end
	end
end

IconButton.draw = function(self)
	self.button:draw()
end

return IconButton
