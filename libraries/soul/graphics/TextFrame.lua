soul.graphics.TextFrame = createClass(soul.graphics.Text)
local TextFrame = soul.graphics.TextFrame

TextFrame.align = {
	x = "left", y = "top"
}

TextFrame.getY = function(self, lineCount)
	local y = self.cs:Y(self.y, true)
	local h = self.cs:Y(self.h)
	if self.align.y == "center" then
		return y + (h - self.font:getHeight() * lineCount * self.scale) / 2
	elseif self.align.y == "bottom" then
		return y + h - self.font:getHeight() * lineCount * self.scale
	else
		return y
	end
end