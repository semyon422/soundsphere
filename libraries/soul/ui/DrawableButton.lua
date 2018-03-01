soul.ui.DrawableButton = createClass(soul.ui.Button)
local DrawableButton = soul.ui.DrawableButton

DrawableButton.drawablePadding = {
	x = 0, y = 0
}

DrawableButton.loadBackground = function(self)
	self.drawableObject = soul.graphics.DrawableFrame:new({
		x = self.x + self.drawablePadding.x,
		y = self.y + self.drawablePadding.y,
		w = self.w - 2 * self.drawablePadding.x,
		h = self.h - 2 * self.bdrawablePadding.y,
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
	self.drawableObject:remove()
end