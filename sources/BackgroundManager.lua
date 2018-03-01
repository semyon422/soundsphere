BackgroundManager = createClass(soul.SoulObject)

BackgroundManager.layer = 0

BackgroundManager.load = function(self)
	self.cs = soul.CS:new(nil, 0, 0, 0, 0)
	
	self.drawableObject = soul.graphics.Drawable:new({
		drawable = self.drawable,
		layer = self.layer,
		cs = self.cs,
		x = 0,
		y = 0,
		sx = 1,
		sy = 1
	})
	self.drawableObject:activate()
	
	self.loaded = true
end

BackgroundManager.getScale = function(self)
	local scale = 1
	local s1 = self.cs.screenWidth / self.cs.screenHeight <= self.drawable:getWidth() / self.drawable:getHeight()
	local s2 = self.cs.screenWidth / self.cs.screenHeight >= self.drawable:getWidth() / self.drawable:getHeight()
	
	if s1 then
		scale = self.cs.screenHeight / self.drawable:getHeight()
	elseif s2 then
		scale = self.cs.screenWidth / self.drawable:getWidth()
	end
	
	return scale
end

BackgroundManager.update = function(self)
	local scale = self:getScale()
	self.drawableObject.sx = scale
	self.drawableObject.sy = scale
	
	self.drawableObject.x = self.cs:x(self.cs.screenWidth - self.drawable:getWidth() * scale) / 2
	self.drawableObject.y = self.cs:y(self.cs.screenHeight - self.drawable:getHeight() * scale) / 2
end

BackgroundManager.unload = function(self)
    self.drawableObject:deactivate()
	
	self.loaded = false
end