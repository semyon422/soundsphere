local Theme = require("aqua.ui.Theme")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local ModsMenu	= require("sphere.ui.ModsMenu")
local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")

local Footer = {}

Footer.csall = CoordinateManager:getCS(0, 0, 0, 0, "all")
Footer.csmin = CoordinateManager:getCS(0.5, 1, 0.5, 1, "min")

Footer.load = function(self)
	self.font = self.font or aquafonts.getFont(spherefonts.NotoSansRegular, 14)
	
	self.bottomButton = Theme.Button:new({
		x = 0,
		y = 1 - 67/1080,
		w = 1,
		h = 67/1080,
		cs = self.csall,
		mode = "fill",
		backgroundColor = {0, 0, 0, 127}
	})
	self.bottomButton:reload()
	
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
		interact = function() ModsMenu:show() end
	})
	self.modsButton:reload()
end

Footer.draw = function(self)
	self.bottomButton:draw()
	self.modsButton:draw()
end

Footer.receive = function(self, event)
	self.bottomButton:receive(event)
	self.modsButton:receive(event)
end

return Footer
