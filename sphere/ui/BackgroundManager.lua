local CS = require("aqua.graphics.CS")
local DrawableFrame = require("aqua.graphics.DrawableFrame")
local image = require("aqua.image")
local DrawableBackground = require("sphere.ui.DrawableBackground")
local tween = require("tween")

local BackgroundManager = {}

BackgroundManager.color = {0, 0, 0}

BackgroundManager.init = function(self)
	self.state = 0
	self.defaultDrawable = love.graphics.newImage(love.image.newImageData(1, 1))
	
	self.cs = CS:new({
		bx = 0,
		by = 0,
		rx = 0,
		ry = 0,
		binding = "all"
	})
	
	self.backgrounds = {}
end

BackgroundManager.loadDrawableBackground = function(self, path)
	return image.load(path, function(imageData)
		if imageData then return self:setDrawableBackground(imageData) end
	end)
end

BackgroundManager.setColor = function(self, color)
	love.timer.step()
	self.colorTween = tween.new(0.5, self.color, color, "inOutQuad")
end

BackgroundManager.setDrawableBackground = function(self, imageData)
	self:setBackground(
		DrawableBackground:new({
			drawable = love.graphics.newImage(imageData),
			cs = self.cs,
			color = {255, 255, 255, 0},
			globalColor = self.color
		})
	)
end

BackgroundManager.setBackground = function(self, background)
	local layer = math.min(#self.backgrounds + 1, 3)
	self.backgrounds[layer] = background
	background:load()
end

BackgroundManager.update = function(self, dt)
	if self.colorTween then self.colorTween:update(dt) end
	
	for i = 1, #self.backgrounds do
		self.backgrounds[i]:update()
	end
	
	if #self.backgrounds > 1 then
		local background = self.backgrounds[2]
		if background.visible == -1 then
			background:fadeIn()
		end
		if background.visible == 1 then
			table.remove(self.backgrounds, 1)
		end
	elseif #self.backgrounds == 1 then
		local background = self.backgrounds[1]
		if background.visible == -1 then
			background:fadeIn()
		end
	end
end

BackgroundManager.draw = function(self)
	for i = 1, #self.backgrounds do
		self.backgrounds[i]:draw()
	end
end

BackgroundManager.receive = function(self, event)
	if event.name == "resize" then
		self:reload()
	end
	for i = 1, #self.backgrounds do
		self.backgrounds[i]:receive(event)
	end
end

BackgroundManager.reload = function(self, event)
	self.cs:reload()
	for i = 1, #self.backgrounds do
		self.backgrounds[i]:reload()
	end
end

return BackgroundManager
