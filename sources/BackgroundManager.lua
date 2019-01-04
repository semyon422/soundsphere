BackgroundManager = createClass(soul.SoulObject)

BackgroundManager.layer = 0

BackgroundManager.load = function(self)
	self.resourceLoader = ResourceLoader:global()
	self.resourceLoader:addObserver(self.observer)
	
	-- self.defaultDrawable = love.graphics.newImage()
	self.state = 0
	
	self.cs = soul.CS:new(nil, 0, 0, 0, 0, "h")
	
	self.drawableObjectBackground = soul.graphics.DrawableFrame:new({
		drawable = self.defaultDrawable,
		layer = self.layer,
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
	
	self.drawableObjectForeground = soul.graphics.DrawableFrame:new({
		drawable = self.defaultDrawable,
		layer = self.layer + 0.001,
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
end

BackgroundManager.setBackground = function(self, filePath)
	self.core.resourceLoader:loadData({
		dataType = "imageData",
		action = "load",
		filePath = filePath,
		index = filePath
	})
end

BackgroundManager.receiveEvent = function(self, event)
	if event.name == "love.update" then
		self:update()
	elseif event.resource and event.action == "load" and event.dataType == "imageData" then
		self:updateBackground(event)
	end
end

BackgroundManager.updateBackground = function(self, event)
	self.state = 1
	self.drawableObjectForeground.drawable = love.graphics.newImage(event.resource)
end

BackgroundManager.update = function(self)
	if self.state == 1 then
		self.drawableObjectForeground.color[4] = self.drawableObjectForeground.color[4] + love.timer.getDelta() * 1000
		if self.drawableObjectForeground.color[4] > 255 then
			self.state = 0
			self.drawableObjectForeground.color[4] = 0
			self.drawableObjectBackground.drawable = self.drawableObjectForeground.drawable
		end
	end
	self.drawableObjectBackground.w = self.cs:x(self.cs.screenWidth)
	self.drawableObjectForeground.w = self.cs:x(self.cs.screenWidth)
	
	if self.drawableObjectBackground.drawable and not self.drawableObjectBackground.loaded then
		self.drawableObjectBackground:activate()
	end
	if self.drawableObjectForeground.drawable and not self.drawableObjectForeground.loaded then
		self.drawableObjectForeground:activate()
	end
end

BackgroundManager.unload = function(self)
end