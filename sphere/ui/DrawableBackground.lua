local CS = require("aqua.graphics.CS")
local map = require("aqua.math").map
local DrawableFrame = require("aqua.graphics.DrawableFrame")

local Background = require("sphere.ui.Background")

local DrawableBackground = Background:new()

DrawableBackground.parallax = 0.0125

DrawableBackground.load = function(self)
	self.drawableFrame = DrawableFrame:new({
		drawable = self.drawable,
		cs = self.cs,
		x = 0 - self.parallax,
		y = 0 - self.parallax,
		h = 1 + 2 * self.parallax,
		w = 1 + 2 * self.parallax,
		locate = "out",
		align = {
			x = "center",
			y = "center"
		},
		color = self.color
	})
	self.drawableFrame:reload()
end

DrawableBackground.getColor = function(self)
	return {
		self.globalColor[1] * self.color[1] / 255,
		self.globalColor[2] * self.color[2] / 255,
		self.globalColor[3] * self.color[3] / 255,
		self.color[4]
	}
end

DrawableBackground.reload = function(self)
	local drawableFrame = self.drawableFrame

	drawableFrame.drawable = self.drawable
	drawableFrame.cs = self.cs
	drawableFrame.color = self:getColor()
	
	self.drawableFrame:reload()
end

DrawableBackground.update = function(self)
	self.drawableFrame.color = self:getColor()
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

DrawableBackground.fadeIn = function(self)
	if self.visible == -1 then
		self.state = 1
		self.visible = 0
	end
end

DrawableBackground.fadeOut = function(self)
	if self.visible == 1 then
		self.state = -1
		self.visible = 0
	end
end

DrawableBackground.receive = function(self, event)
	if event.name == "mousemoved" then
		local mx = self.cs:x(event.args[1], true)
		local my = self.cs:y(event.args[2], true)
		self.drawableFrame.x = 0 - map(mx, 0, 1, self.parallax, 0)
		self.drawableFrame.y = 0 - map(my, 0, 1, self.parallax, 0)
		self.drawableFrame.w = 1 + 2 * self.parallax
		self.drawableFrame.h = 1 + 2 * self.parallax
		self.drawableFrame:reload()
	end
end

return DrawableBackground
