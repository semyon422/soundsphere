local Theme = require("aqua.ui.Theme")
local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local NotificationLine = {}

NotificationLine.rectangleColor = {255, 255, 255, 31}
NotificationLine.textColor = {255, 255, 255, 255}
NotificationLine.maxlifetime = 1
NotificationLine.lifetime = 0

NotificationLine.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
	
	self.state = 0
	
	self.button = Theme.Button:new({
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
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
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
		return self.button:reload()
	elseif event.name == "notify" then
		return self:notify(event.text)
	end
end

return NotificationLine
