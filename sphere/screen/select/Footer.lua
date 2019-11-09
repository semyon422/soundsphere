local aquafonts			= require("aqua.assets.fonts")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Theme				= require("aqua.ui.Theme")
local spherefonts		= require("sphere.assets.fonts")
local ModifierMenu		= require("sphere.screen.select.ModifierMenu")
local NoteSkinMenu		= require("sphere.screen.select.NoteSkinMenu")

local Footer = {}

Footer.init = function(self)
	self.csall = CoordinateManager:getCS(0, 0, 0, 0, "all")
	self.csmin = CoordinateManager:getCS(0.5, 1, 0.5, 1, "min")
	
	self.font = aquafonts.getFont(spherefonts.NotoSansRegular, 14)
	
	self.bottomButton = Theme.Button:new({
		x = 0,
		y = 1 - 67/1080,
		w = 1,
		h = 67/1080,
		cs = self.csall,
		mode = "fill",
		backgroundColor = {0, 0, 0, 127}
	})
	
	self.modsButton = Theme.Button:new({
		text = "mods",
		font = self.font,
		x = 0,
		y = 1 - 67/1080,
		w = 1/8,
		limit = 1/8,
		h = 67/1080,
		cs = self.csmin,
		mode = "fill",
		textAlign = {x = "center", y = "center"},
		backgroundColor = {0, 0, 0, 127},
		interact = function() ModifierMenu:show() end
	})
	
	self.skinButton = Theme.Button:new({
		text = "skin",
		font = self.font,
		x = 1/8,
		y = 1 - 67/1080,
		w = 1/8,
		limit = 1/8,
		h = 67/1080,
		cs = self.csmin,
		mode = "fill",
		textAlign = {x = "center", y = "center"},
		backgroundColor = {0, 0, 0, 127},
		interact = function() NoteSkinMenu:show() end
	})
end

Footer.reload = function(self)
	self.bottomButton:reload()
	self.modsButton:reload()
	self.skinButton:reload()
end

Footer.draw = function(self)
	self.bottomButton:draw()
	self.modsButton:draw()
	self.skinButton:draw()
end

Footer.receive = function(self, event)
	self.bottomButton:receive(event)
	self.modsButton:receive(event)
	self.skinButton:receive(event)
end

return Footer
