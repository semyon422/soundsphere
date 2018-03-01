soul.ui.TextButton = createClass(soul.ui.Button)
local TextButton = soul.ui.TextButton

TextButton.textPadding = {
	x = 0, y = 0
}

TextButton.loadForeground = function(self)
	self.textObject = soul.graphics.TextFrame:new({
		x = self.x + self.textPadding.x,
		y = self.y + self.textPadding.y,
		w = self.w - 2 * self.textPadding.x,
		h = self.h - 2 * self.textPadding.y,
		limit = self.limit,
		align = self.textAlign,
		text = self.text,
		font = self.font,
		color = self.textColor,
		layer = self.layer + 1,
		cs = self.cs
	})
	self.textObject:activate()
end

TextButton.unloadForeground = function(self)
	self.textObject:deactivate()
end