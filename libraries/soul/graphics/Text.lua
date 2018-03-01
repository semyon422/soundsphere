soul.graphics.Text = createClass(soul.graphics.GraphicalObject)
local Text = soul.graphics.Text

Text.align = {
	x = "left", y = "bottom"
}
Text.font = love.graphics.getFont()
Text.color = {love.graphics.getColor()}
Text.limit = math.huge

Text.getY = function(self, lineCount)
	local y = self.cs:Y(self.y, true)
	if self.align.y == "center" then
		return y - self.font:getHeight() * self.scale * lineCount / 2
	elseif self.align.y == "top" then
		return y - self.font:getHeight() * self.scale * lineCount
	else
		return y
	end
end

Text.draw = function(self)
	self.scale = self.cs.one / self.cs.baseOne
	
	local limit = self.cs:X(self.limit) / self.scale
	
	local width, wrappedText = self.font:getWrap(self.text, limit)
	local lineCount = #wrappedText
	
	local y = self:getY(lineCount)
	
	self:switchColor(true)
	self:switchFont(true)
	
	love.graphics.printf(
		{self.color, self.text},
		self.cs:X(self.x, true),
		y,
		limit,
		self.align.x,
		self.r,
		self.scale,
		self.scale,
		self.cs:X(self.ox),
		self.cs:Y(self.oy),
		self.kx,
		self.ky
	)
	
	self:switchColor()
	self:switchFont()
end