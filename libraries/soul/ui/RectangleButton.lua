soul.ui.RectangleButton = createClass(soul.ui.Button)
local RectangleButton = soul.ui.RectangleButton

RectangleButton.loadBackground = function(self)
	self.rectangleObject = soul.graphics.Rectangle:new({
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		mode = self.mode,
		color = self.rectangleColor,
		layer = self.layer,
		cs = self.cs
	})
	self.rectangleObject:activate()
end

RectangleButton.unloadBackground = function(self)
	self.rectangleObject:deactivate()
end