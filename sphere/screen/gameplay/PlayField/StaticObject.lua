local Class = require("aqua.util.Class")
local Image = require("aqua.graphics.Image")

local StaticObject = Class:new()

StaticObject.load = function(self)
	self.image = love.graphics.newImage(self.playField.directoryPath .. "/" .. self.image)
	self.drawable = Image:new({
		image = self.image,
		layer = self.layer,
		cs = self.cs,
		x = self.x,
		y = self.y,
		sx = 1,
		sy = 1,
		color = {255, 255, 255, 255}
	})
	self.drawable:reload()
	self.container:add(self.drawable)
end

StaticObject.update = function(self)
	self.drawable.sx = self.cs:X(1) / self.image:getWidth() * self.w
	self.drawable.sy = self.cs:Y(1) / self.image:getHeight() * self.h
	self.drawable:reload()
end

StaticObject.unload = function(self)
	self.container:remove(self.drawable)
end

return StaticObject
