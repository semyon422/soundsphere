local Theme = require("aqua.ui.Theme")

local Header = {}

Header.load = function(self)
	self.topButton = Theme.Button:new({
		x = self.topx,
		y = self.topy,
		w = self.topw,
		h = self.toph,
		cs = self.cs,
		mode = "fill",
		backgroundColor = self.topColor
	})
	self.bottomButton = Theme.Button:new({
		x = self.bottomx,
		y = self.bottomy,
		w = self.bottomw,
		h = self.bottomh,
		cs = self.cs,
		mode = "fill",
		backgroundColor = self.bottomColor
	})
	self.topButton:reload()
	self.bottomButton:reload()
end

Header.draw = function(self)
	self.topButton:draw()
	self.bottomButton:draw()
end

Header.receive = function(self, event)
	if event.name == "resize" then
		self.topButton:reload()
		self.bottomButton:reload()
	end
end

return Header
