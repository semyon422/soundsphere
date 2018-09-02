PlayField.StaticObject = createClass(soul.SoulObject)
local StaticObject = PlayField.StaticObject

StaticObject.load = function(self)
	self.drawable = love.graphics.newImage(self.playField.directoryPath .. "/" .. self.image)
	self.drawableObject = soul.graphics.Drawable:new({
		drawable = self.drawable,
		layer = self.layer,
		cs = self.cs,
		x = self.x,
		y = self.y,
		sx = 1,
		sy = 1
	})
	self.drawableObject:activate()
end

StaticObject.update = function(self)
	self.drawableObject.sx = self.cs:X(1) / self.drawable:getWidth() * self.w
	self.drawableObject.sy = self.cs:Y(1) / self.drawable:getHeight() * self.h
end

StaticObject.unload = function(self)
	self.drawableObject:deactivate()
end

StaticObject.receiveEvent = function(self, event)
	if event.name == "love.update" then
		self:update()
	end
end