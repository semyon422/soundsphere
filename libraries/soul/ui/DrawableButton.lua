soul.ui.DrawableButton = createClass(soul.ui.Button)
local DrawableButton = soul.ui.DrawableButton

DrawableButton.loadBackground = function(self)
	self.drawableObject = soul.graphics.DrawableFrame:new({
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		align = self.drawableAlign,
		drawable = self.drawable,
		color = self.drawableColor,
		locate = self.locate,
		layer = self.layer,
		cs = self.cs
	})
	self.drawableObject:activate()
end

DrawableButton.unloadBackground = function(self)
	self.drawableObject:deactivate()
end