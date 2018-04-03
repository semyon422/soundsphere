soul.graphics.DrawableFrame = createClass(soul.graphics.GraphicalObject)
local DrawableFrame = soul.graphics.DrawableFrame

DrawableFrame.updateScale = function(self)
	self.scale = 1
	local dw = self.drawable:getWidth()
	local dh = self.drawable:getHeight()
	local s1 = self.w / self.h <= dw / dh
	local s2 = self.w / self.h >= dw / dh
	
	if self.locate == "out" and s1 or self.locate == "in" and s2 then
		self.scale = self.cs:Y(self.h) / dh
	elseif self.locate == "out" and s2 or self.locate == "in" and s1 then
		self.scale = self.cs:X(self.w) / dw
	end
end

DrawableFrame.getOffset = function(self, screen, frame, align)
	if align == "center" then
		return (screen - frame) / 2
	elseif align == "left" or align == "top" then
		return 0
	elseif align == "right" or align == "bottom" then
		return screen - frame
	end
end

DrawableFrame.updateOffsets = function(self)
	self.ox = self:getOffset(self.cs:X(self.w), self.drawable:getWidth() * self.scale, self.align.x)
	self.oy = self:getOffset(self.cs:Y(self.h), self.drawable:getHeight() * self.scale, self.align.y)
end

DrawableFrame.draw = function(self)
	self:updateScale()
	self:updateOffsets()
	self:switchColor(true)
	
	love.graphics.draw(
		self.drawable,
		self.cs:X(self.x, true) + self.ox,
		self.cs:Y(self.y, true) + self.oy,
		self.r,
		self.scale,
		self.scale
	)
	
	self:switchColor()
end