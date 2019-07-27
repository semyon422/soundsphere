local Theme = require("aqua.ui.Theme")

local Footer = {}

Footer.load = function(self)
	self.bottomButton = Theme.Button:new({
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.y,
		cs = self.cs,
		mode = "fill",
		backgroundColor = self.color
	})
	self.bottomButton:reload()
end

Footer.draw = function(self)
	self.bottomButton:draw()
end

Footer.receive = function(self, event)
	if event.name == "resize" then
		self.bottomButton:reload()
	end
end

return Footer
