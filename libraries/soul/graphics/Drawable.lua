soul.graphics.Drawable = createClass(soul.graphics.GraphicalObject)
local Drawable = soul.graphics.Drawable

Drawable.draw = function(self)
	self:switchColor(true)
	
	love.graphics.draw(
		self.drawable,
		self.cs:X(self.x, true),
		self.cs:Y(self.y, true),
		self.r,
		self.sx,
		self.sy,
		self.cs:X(self.ox),
		self.cs:X(self.oy)
	)
	
	self:switchColor()
end