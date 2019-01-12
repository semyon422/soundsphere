local CS = require("aqua.graphics.CS")
local DrawableFrame = require("aqua.graphics.DrawableFrame")
local image = require("aqua.image")

local BackgroundManager = {}

BackgroundManager.init = function(self)
	self.state = 0
	self.defaultDrawable = love.graphics.newImage(love.image.newImageData(1, 1))
	
	self.cs = CS:new({
		bx = 0,
		by = 0,
		rx = 0,
		ry = 0,
		binding = "h"
	})
	
	self.background = DrawableFrame:new({
		drawable = self.defaultDrawable,
		cs = self.cs,
		x = 0,
		y = 0,
		h = 1,
		w = 1,
		locate = "out",
		align = {
			x = "center",
			y = "center"
		},
		color = {255, 255, 255, 255}
	})
	self.background:reload()
	
	self.foreground = DrawableFrame:new({
		drawable = self.defaultDrawable,
		cs = self.cs,
		x = 0,
		y = 0,
		h = 1,
		w = 1,
		locate = "out",
		align = {
			x = "center",
			y = "center"
		},
		color = {255, 255, 255, 0}
	})
	self.foreground:reload()
	
	self.background.w = self.cs:x(self.cs.screenWidth)
	self.foreground.w = self.background.w
end

BackgroundManager.loadBackground = function(self, path)
	return image.load(path, function(imageData)
		if imageData then return self:setBackground(imageData) end
	end)
end

BackgroundManager.setBackground = function(self, imageData)
	self.state = 1
	self.foreground.drawable = love.graphics.newImage(imageData)
	self:reload()
end

BackgroundManager.update = function(self)
	if self.state == 1 then
		self.foreground.color[4] = self.foreground.color[4] + love.timer.getDelta() * 1000
		if self.foreground.color[4] > 255 then
			self.state = 0
			self.foreground.color[4] = 0
			self.background.drawable = self.foreground.drawable
			self:reload()
		end
	end
end

BackgroundManager.draw = function(self)
	self.background:draw()
	self.foreground:draw()
end

BackgroundManager.receive = function(self, event)
	if event.name == "resize" then
		self:reload()
	end
end

BackgroundManager.reload = function(self, event)
	self.cs:reload()
	self.background.w = self.cs:x(self.cs.screenWidth)
	self.foreground.w = self.background.w
	self.background:reload()
	self.foreground:reload()
end

return BackgroundManager
