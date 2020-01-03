local aquafonts			= require("aqua.assets.fonts")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local TextFrame			= require("aqua.graphics.TextFrame")
local Class				= require("aqua.util.Class")
local spherefonts		= require("sphere.assets.fonts")

local TextDisplay = Class:new()

TextDisplay.loadGui = function(self)
	self.cs = CoordinateManager:getCS(unpack(self.data.cs))
	self.x = self.data.x
	self.y = self.data.y
	self.w = self.data.w
	self.h = self.data.h
	self.layer = self.data.layer
	self.color = self.data.color
	self.align = self.data.align
	self.font = self.data.font
	self.size = self.data.size
	self.format = self.data.format
	self.field = self.data.field

	self.score = self.gui.score
	self.container = self.gui.container
	
	self:load()
end

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

TextDisplay.reload = function(self)
	self.textFrame:reload()
end

TextDisplay.receive = function(self, event) end

return TextDisplay
