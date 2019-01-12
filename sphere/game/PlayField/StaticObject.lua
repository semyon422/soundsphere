local Class = require("aqua.util.Class")
local Drawable = require("aqua.graphics.Drawable")

local StaticObject = Class:new()

StaticObject.load = function(self)
	self.drawable = love.graphics.newImage(self.playField.directoryPath .. "/" .. self.image)
	self.drawableObject = Drawable:new({
		drawable = self.drawable,
		layer = self.layer,
		cs = self.cs,
		x = self.x,
		y = self.y,
		sx = 1,
		sy = 1,
		color = {255, 255, 255, 255}
	})
	self.drawableObject:reload()
	self.container:add(self.drawableObject)
end

StaticObject.update = function(self)
	self.drawableObject.sx = self.cs:X(1) / self.drawable:getWidth() * self.w
	self.drawableObject.sy = self.cs:Y(1) / self.drawable:getHeight() * self.h
	self.drawableObject:reload()
end

StaticObject.unload = function(self)
	self.container:remove(self.drawableObject)
end

return StaticObject
