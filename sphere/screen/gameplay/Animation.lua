local Class				= require("aqua.util.Class")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Image				= require("aqua.graphics.Image")

local Animation = Class:new()

Animation.loadGui = function(self)
	self.cs = CoordinateManager:getCS(unpack(self.data.cs))
	self.x = self.data.x
	self.y = self.data.y
	self.w = self.data.w
	self.h = self.data.h
	self.layer = self.data.layer
	self.image = self.data.image
	self.interval = self.data.interval
	self.fps = self.data.fps

	self.container = self.gui.container

	self.images = {}
	
	self:load()
end

Animation.load = function(self)
	local images = self.images
	local interval = self.interval

	for i = interval[1], interval[2] do
		images[#images + 1] = love.graphics.newImage(self.image:format(i))
	end

	self.counter = 0
	self.index = 1
	self.drawable = Image:new({
		image = images[1],
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

Animation.update = function(self, dt)
	self.counter = self.counter + dt
	if self.counter > 1 / self.fps then
		self.index = self.index % #self.images + 1
		self.drawable.image = self.images[self.index]
		self.counter = self.counter - 1 / self.fps
	end
	self.drawable.sx = self.cs:X(1) / self.drawable.image:getWidth() * self.w
	self.drawable.sy = self.cs:Y(1) / self.drawable.image:getHeight() * self.h
	self.drawable:reload()
end

Animation.unload = function(self)
	self.container:remove(self.drawable)
end

Animation.reload = function(self)
	self.drawable:reload()
end

Animation.receive = function(self, event) end

return Animation
