soul.graphics.Quad = createClass(soul.graphics.GraphicalObject)
local Quad = soul.graphics.Quad

Quad.draw = function(self)
	self:switchColor(true)
	
	love.graphics.draw(
		self.drawable,
		self.quad,
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