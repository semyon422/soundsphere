local Button = require("aqua.ui.Button")
local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")
local CS = require("aqua.graphics.CS")

local NotificationLine = {}

NotificationLine.rectangleColor = {255, 255, 255, 31}
NotificationLine.textColor = {255, 255, 255, 255}
NotificationLine.maxlifetime = 1
NotificationLine.lifetime = 0

NotificationLine.init = function(self)
	self.cs = CS:new({
		bx = 0,
		by = 0,
		rx = 0,
		ry = 0,
		binding = "all",
		baseOne = 576
	})
	
	self.state = 0
	
	self.button = Button:new({
		text = "",
		x = 0,
		y = 8 / 17,
		w = 1,
		h = 1 / 17,
		cs = self.cs,
		mode = "fill",
		rectangleColor = {unpack(self.rectangleColor)},
		textColor = {unpack(self.textColor)},
		textAlign = {x = "center", y = "center"},
		limit = 1,
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 20)
	})
	self.button:reload()
	self.button.rectangleColor[4] = 0
	self.button.textColor[4] = 0
end

NotificationLine.notify = function(self, text)
	self.state = 1
	self.lifetime = 0
	self.button.rectangleColor[4] = self.rectangleColor[4]
	self.button.textColor[4] = self.textColor[4]
	self.button:setText(text)
end

NotificationLine.update = function(self)
	if self.state == 1 then
		if self.lifetime < self.maxlifetime then
			self.lifetime = self.lifetime + love.timer.getDelta()
		else
			self.button.rectangleColor[4] = math.max(self.button.rectangleColor[4] - love.timer.getDelta() * 125, 0)
			self.button.textColor[4] = math.max(self.button.textColor[4] - love.timer.getDelta() * 1000, 0)
			
			if self.button.textColor[4] == 0 then
				self.state = 0
				self.button.rectangleColor[4] = 0
				self.button.textColor[4] = 0
				self.lifetime = 0
			end
		end
	end
end

NotificationLine.draw = function(self)
	self.button:draw()
end

NotificationLine.receive = function(self, event)
	if event.name == "resize" then
		self.cs:reload()
		return self.button:reload()
	end
end

return NotificationLine
