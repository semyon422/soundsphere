local Class = require("aqua.util.Class")
local TextFrame = require("aqua.graphics.TextFrame")
local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")

local TextDisplay = Class:new()

TextDisplay.load = function(self)
	self.textFrame = TextFrame:new({
		text = "",
		layer = self.layer,
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		cs = self.cs,
		limit = self.w,
		align = self.align,
		color = self.color,
		font = aquafonts.getFont(self.font, self.size)
	})
	self.textFrame:reload()
	self.container:add(self.textFrame)
end

TextDisplay.update = function(self)
	self.textFrame.text = self:getText()
	self.textFrame:reload()
end

TextDisplay.unload = function(self)
	self.container:remove(self.textFrame)
end

TextDisplay.receive = function(self, event) end

return TextDisplay
