local Class				= require("aqua.util.Class")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local ImageFrame		= require("aqua.graphics.ImageFrame")
local AquaImageButton		= require("aqua.ui.ImageButton")

local ImageButton = Class:new()

ImageButton.loadGui = function(self)
	self.cs = CoordinateManager:getCS(unpack(self.data.cs))
	self.x = self.data.x
	self.y = self.data.y
	self.w = self.data.w
	self.h = self.data.h
	self.scale = self.data.scale or 1
	self.layer = self.data.layer

	self.interact = function()
		local events = self.data.events
		if not events then return end
		for i = 1, #events do
			self.gui.observable:send(events[i])
		end
	end

	self.imagePath = self.data.image
	self.container = self.gui.container

	self:load()
end

ImageButton.load = function(self)
	self.image = love.graphics.newImage(self.imagePath)
	self.drawable = ImageFrame:new({
		image = self.image,
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		cs = self.cs,
		scale = self.scale,
		layer = self.layer,
		locate = "in",
		align = {
			x = "center",
			y = "center"
		}
	})
	
	self.button = AquaImageButton:new({
		drawable = self.drawable,
		interact = self.interact
	})
	self.button:reload()

	self.container:add(self.drawable)
end

ImageButton.unload = function(self)
	self.container:remove(self.drawable)
end

ImageButton.reload = function(self)
	self.drawable:reload()
	self.button:reload()
end

ImageButton.update = function(self)
	self.button:update()
end

ImageButton.receive = function(self, event)
	self.button:receive(event)
end

return ImageButton
