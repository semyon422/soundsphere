local Class = require("aqua.util.Class")
local Image = require("aqua.graphics.Image")

local InputObject = Class:new()

InputObject.load = function(self)
	self.imageReleased = love.graphics.newImage(self.playField.directoryPath .. "/" .. self.released)
	self.imagePressed = love.graphics.newImage(self.playField.directoryPath .. "/" .. (self.pressed or self.released))
	self.drawable = Image:new({
		image = self.imageReleased,
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

InputObject.update = function(self)
	self.drawable.sx = self.cs:X(1) / self.drawable.image:getWidth() * self.w
	self.drawable.sy = self.cs:Y(1) / self.drawable.image:getHeight() * self.h
	self.drawable:reload()
end

InputObject.unload = function(self)
	self.container:remove(self.drawable)
end

InputObject.receive = function(self, event)
	if event.name == "noteHandlerUpdated" then
		if
			event.noteHandler.inputType == self.inputType and
			event.noteHandler.inputIndex == self.inputIndex
		then
			if event.noteHandler.keyState == true then
				self.drawable.image = self.imagePressed
			else
				self.drawable.image = self.imageReleased
			end
		end
	end
end

return InputObject
