soul.graphics.DrawableFrame = createClass(soul.graphics.GraphicalObject)
local DrawableFrame = soul.graphics.DrawableFrame

DrawableFrame.getScale = function(self)
	local scale = 1
	local s1 = self.cs.screenWidth / self.cs.screenHeight <= 1
	local s2 = self.cs.screenWidth / self.cs.screenHeight >= 1
	
	if self.locate == "out" and s1 or self.locate == "in" and s2 then
		scale = self.cs.screenHeight / self.drawable:getHeight()
	elseif self.locate == "out" and s2 or self.locate == "in" and s1 then
		scale = self.cs.screenWidth / self.drawable:getWidth()
	end
	
	return scale
end

DrawableFrame.getOffset = function(self, cScreen, cFrame, align)
	if align == "center" then
		return 0
	elseif align == "left" or align == "top" then
		return (cFrame - cScreen) / 2
	elseif align == "right" or align == "bottom" then
		return (cScreen - cFrame) / 2
	end
end

DrawableFrame.getOffsets = function(self)
	self.ox = self:getOffset(self.cs.screenWidth, self.drawable:getWidth(), self.align.x)
	self.oy = self:getOffset(self.cs.screenHeight, self.drawable:getHeight(), self.align.y)
end

DrawableFrame.draw = function(self)
	self:getOffsets()
	self:switchColor(true)
	
	love.graphics.draw(
		self.drawable,
		self.cs:X(0.5, true) + (self.cs.screenWidth - self.drawable:getWidth()) / 2 + self.ox,
		self.cs:Y(0.5, true) + (self.cs.screenHeight - self.drawable:getHeight()) / 2 + self.oy,
		self.r,
		self:getScale(),
		self:getScale()
	)
	
	self:switchColor()
end