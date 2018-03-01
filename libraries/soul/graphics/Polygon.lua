soul.graphics.Polygon = createClass(soul.graphics.GraphicalObject)
local Polygon = soul.graphics.Polygon

Polygon.draw = function(self)
	self:switchColor(true)
	
	love.graphics.polygon(self.mode, self.vertices)
	
	self:switchColor()
end