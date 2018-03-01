soul.graphics.Circle = createClass(soul.graphics.GraphicalObject)
local Circle = soul.graphics.Circle

Circle.draw = function(self)
	local oldColor = {love.graphics.getColor()}
	love.graphics.setColor(self.color)
	
	love.graphics.circle(
		self.mode,
		self.cs:X(self.x, true),
		self.cs:Y(self.y, true),
		self.cs:X(self.r)
	)
	
	love.graphics.setColor(oldColor)
end