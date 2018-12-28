NotificationLine = createClass(soul.SoulObject)

NotificationLine.x = 0
NotificationLine.y = 8 * 1 / 17
NotificationLine.w = 1
NotificationLine.h = 1 / 17
NotificationLine.layer = 4
NotificationLine.rectangleColor = {255, 255, 255, 31}
NotificationLine.textColor = {255, 255, 255, 255}
NotificationLine.mode = "fill"
NotificationLine.limit = 1
NotificationLine.textAlign = {
	x = "center", y = "center"
}
NotificationLine.buttonCount = 17

NotificationLine.fontType = "sans-regular"
NotificationLine.fontSize = 20
NotificationLine.maxlifetime = 1
NotificationLine.lifetime = 0

NotificationLine.load = function(self)
	self.cs = soul.CS:new(nil, 0, 0, 0, 0, "all", 576)
	
	self:sendEvent({
		name = "resource",
		type = "font",
		fontType = self.fontType,
		fontSize = self.fontSize,
		callback = function(font)
			self.font = font
		end
	})
	
	self.state = 0
	
	self.button = soul.ui.RectangleTextButton:new({
		text = "",
		action = function() end,
		t = 1,
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		layer = self.layer,
		cs = self.cs,
		rectangleColor = {unpack(self.rectangleColor)},
		mode = self.mode,
		limit = self.limit,
		textAlign = self.textAlign,
		textColor = {unpack(self.textColor)},
		font = self.font
	})
	self.button.rectangleColor[4] = 0
	self.button.textColor[4] = 0
	self.button:activate()
end

NotificationLine.receiveEvent = function(self, event)
	if event.name == "love.update" then
		self:update()
	end
end

NotificationLine.update = function(self)
	if self.state == 1 then
		if self.lifetime < self.maxlifetime then
			self.lifetime = self.lifetime + love.timer.getDelta()
		else
			self.button.rectangleColor[4] = math.max(self.button.rectangleColor[4] - love.timer.getDelta() * 1000, 0)
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

NotificationLine.setText = function(self, text)
	self.state = 1
	self.lifetime = 0
	self.button.rectangleColor[4] = self.rectangleColor[4]
	self.button.textColor[4] = self.textColor[4]
	self.button.textObject.text = text
end