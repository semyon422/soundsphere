local CS = require("aqua.graphics.CS")
local DrawableFrame = require("aqua.graphics.DrawableFrame")

local Background = require("sphere.ui.Background")

local DrawableBackground = Background:new()

DrawableBackground.load = function(self)
	self.drawableFrame = DrawableFrame:new({
		drawable = self.drawable,
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
		color = self.color
	})
	self.drawableFrame:reload()
end

DrawableBackground.reload = function(self)
	local drawableFrame = self.drawableFrame

	drawableFrame.drawable = self.drawable
	drawableFrame.cs = self.cs
	drawableFrame.color = self.color
	
	self.drawableFrame:reload()
end

DrawableBackground.update = function(self)
	self.drawableFrame:update()
	
	if self.state == 1 then
		self.color[4] = math.min(self.color[4] + love.timer.getDelta() * 1000, 255)
		if self.color[4] == 255 then
			self.state = 0
			self.visible = 1
		end
	elseif self.state == -1 then
		self.color[4] = math.max(self.color[4] - love.timer.getDelta() * 1000, 0)
		if self.color[4] == 0 then
			self.state = 0
			self.visible = -1
		end
	end
end

DrawableBackground.draw = function(self)
	self.drawableFrame:draw()
end

Background.fadeIn = function(self)
	if self.visible == -1 then
		self.state = 1
		self.visible = 0
	end
end

Background.fadeOut = function(self)
	if self.visible == 1 then
		self.state = -1
		self.visible = 0
	end
end

return DrawableBackground
