local Class				= require("aqua.util.Class")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Image				= require("aqua.graphics.Image")

local StaticImage = Class:new()

StaticImage.loadGui = function(self)
	self.cs = CoordinateManager:getCS(unpack(self.data.cs))
	self.x = self.data.x
	self.y = self.data.y
	self.w = self.data.w
	self.h = self.data.h
	self.layer = self.data.layer

	self.imagePath = self.data.image
	self.container = self.gui.container

	self:load()
end

StaticImage.load = function(self)
	self.image = love.graphics.newImage(self.imagePath)
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

StaticImage.update = function(self)
	self.drawable.sx = self.cs:X(1) / self.image:getWidth() * self.w
	self.drawable.sy = self.cs:Y(1) / self.image:getHeight() * self.h
	self.drawable:reload()
end

StaticImage.unload = function(self)
	self.container:remove(self.drawable)
end

StaticImage.reload = function(self)
	self.drawable:reload()
end

StaticImage.receive = function(self, event) end

return StaticImage
