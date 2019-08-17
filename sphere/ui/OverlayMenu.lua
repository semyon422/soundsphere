local aquafonts			= require("aqua.assets.fonts")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Rectangle			= require("aqua.graphics.Rectangle")
local TextFrame			= require("aqua.graphics.TextFrame")
local spherefonts		= require("sphere.assets.fonts")
local CustomList		= require("sphere.ui.CustomList")

local OverlayMenu = {}

OverlayMenu.hidden = true
OverlayMenu.csall = CoordinateManager:getCS(0, 0, 0, 0, "all")
OverlayMenu.csmin = CoordinateManager:getCS(0.5, 0.5, 0.5, 0.5, "min")

OverlayMenu.x = 0.1
OverlayMenu.y = 0.1
OverlayMenu.w = 0.8
OverlayMenu.h = 0.8

OverlayMenu.init = function(self)
	self.titleFont = aquafonts.getFont(spherefonts.NotoSansRegular, 30)
	self.textFont = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
	
	self.background = Rectangle:new({
		x = 0,
		y = 0,
		w = 1,
		h = 1,
		color = {0, 0, 0, 191},
		cs = self.csall,
		mode = "fill"
	})
	self.background:reload()
	
	self.titleText = TextFrame:new({
		x = 0,
		y = 0,
		w = 1,
		h = self.y,
		limit = 1,
		align = {x = "center", y = "center"},
		text = "title",
		font = self.titleFont,
		color = {255, 255, 255, 255},
		cs = self.csmin,
		baseScale = 1
	})
	self.titleText:reload()
	
	self.list = CustomList:new({
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		limit = self.w,
		buttonCount = 9,
		middleOffset = 5,
		startOffset = 5,
		endOffset = 5,
		cs = self.csmin,
		textAlign = {x = "center", y = "center"}
	})
	self.list:load()
end

OverlayMenu.hide = function(self)
	self.hidden = true
end

OverlayMenu.show = function(self)
	self.hidden = false
	self:reload()
end

OverlayMenu.setTitle = function(self, title)
	self.titleText.text = title
	self.titleText:reload()
end

OverlayMenu.setItems = function(self, items)
	self.list:setItems(items)
	self.list:reload()
end

OverlayMenu.update = function(self)
	self.list:update()
end

OverlayMenu.draw = function(self)
	if not self.hidden then
		self.background:draw()
		self.titleText:draw()
		self.list:draw()
	end
end

OverlayMenu.reload = function(self)
	self.background:reload()
	self.titleText:reload()
end

OverlayMenu.receive = function(self, event)
	if self.hidden then
		return
	end
	if event.name == "resize" then
		self:reload()
	elseif event.name == "keypressed" and event.args[1] == "escape" then
		self:hide()
	end
	
	self.list:receive(event)
end

return OverlayMenu
