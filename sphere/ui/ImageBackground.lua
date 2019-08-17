local ImageFrame	= require("aqua.graphics.ImageFrame")
local image			= require("aqua.image")
local map			= require("aqua.math").map
local Background	= require("sphere.ui.Background")

local ImageBackground = Background:new()

ImageBackground.parallax = 0.0125

ImageBackground.load = function(self)
	self.drawable = ImageFrame:new({
		image = self.image,
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
	self.drawable:reload()
	
	local mx = self.cs:x(love.mouse.getX(), true)
	local my = self.cs:y(love.mouse.getY(), true)
	self:updateParallax(mx, my)
end

local emptyFunction = function() end
ImageBackground.unload = function(self)
	image.unload(self.path, emptyFunction)
end

ImageBackground.getColor = function(self)
	return {
		self.globalColor[1] * self.color[1] / 255,
		self.globalColor[2] * self.color[2] / 255,
		self.globalColor[3] * self.color[3] / 255,
		self.color[4]
	}
end

ImageBackground.reload = function(self)
	local drawable = self.drawable

	drawable.image = self.image
	drawable.cs = self.cs
	drawable.color = self:getColor()
	
	drawable:reload()
end

ImageBackground.update = function(self)
	self.drawable.color = self:getColor()
	self.drawable:update()
	
	if self.state == 1 then
		self.color[4] = math.min(self.color[4] + love.timer.getDelta() * 2000, 255)
		if self.color[4] == 255 then
			self.state = 0
			self.visible = 1
		end
	elseif self.state == -1 then
		self.color[4] = math.max(self.color[4] - love.timer.getDelta() * 2000, 0)
		if self.color[4] == 0 then
			self.state = 0
			self.visible = -1
		end
	end
end

ImageBackground.draw = function(self)
	self.drawable:draw()
end

ImageBackground.fadeIn = function(self)
	if self.visible == -1 then
		self.state = 1
		self.visible = 0
	end
end

ImageBackground.fadeOut = function(self)
	if self.visible == 1 then
		self.state = -1
		self.visible = 0
	end
end

ImageBackground.receive = function(self, event)
	if event.name == "mousemoved" then
		local mx = self.cs:x(event.args[1], true)
		local my = self.cs:y(event.args[2], true)
		self:updateParallax(mx, my)
	end
end

ImageBackground.updateParallax = function(self, x, y)
	self.drawable.x = 0 - map(x, 0, 1, self.parallax, 0)
	self.drawable.y = 0 - map(y, 0, 1, self.parallax, 0)
	self.drawable.w = 1 + 2 * self.parallax
	self.drawable.h = 1 + 2 * self.parallax
	self.drawable:reload()
end

return ImageBackground
