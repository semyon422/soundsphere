soul.graphics.QuadBox = createClass(soul.graphics.GraphicalObject)
local QuadBox = soul.graphics.QuadBox

QuadBox.draw = function(self)
	self.subcs = self.subcs or soul.CS:new({
		res = {
			w = self.drawable:getWidth(),
			h = self.drawable:getHeight()
		},
		align = self.align,
		locate = self.locate,
		getScreen = function()
			return {
				x = self.cs:X(self.x, true),
				y = self.cs:Y(self.y, true),
				w = self.cs:X(self.w),
				h = self.cs:Y(self.h)
			}
		end
	})
	
	self:switchColor(true)
	
	love.graphics.draw(
		self.drawable,
		self.quad,
		self.subcs:X(0, true),
		self.subcs:Y(0, true),
		self.r,
		self.subcs:s(),
		self.subcs:s(),
		self.cs:X(self.ox),
		self.cs:X(self.oy)
	)
	
	self:switchColor()
end