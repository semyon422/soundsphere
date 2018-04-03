BackgroundManager = createClass(soul.SoulObject)

BackgroundManager.layer = 0

BackgroundManager.load = function(self)
	self.cs = soul.CS:new(nil, 0, 0, 0, 0, "h")
	
	self.drawableObject = soul.graphics.DrawableFrame:new({
		drawable = self.drawable,
		layer = self.layer,
		cs = self.cs,
		x = 0,
		y = 0,
		h = 1,
		w = 1,
		locate = "out",
		align = {
			x = "center",
			y = "center"
		}
	})
	self.drawableObject:activate()
	
	self.loaded = true
end

BackgroundManager.update = function(self)
	self.drawableObject.w = self.cs:x(self.cs.screenWidth)
end

BackgroundManager.unload = function(self)
    self.drawableObject:deactivate()
	
	self.loaded = false
end