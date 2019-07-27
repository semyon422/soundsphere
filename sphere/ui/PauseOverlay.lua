local CoordinateManager = require("aqua.graphics.CoordinateManager")
local Rectangle = require("aqua.graphics.Rectangle")
local aquafonts = require("aqua.assets.fonts")
local Theme = require("aqua.ui.Theme")
local spherefonts = require("sphere.assets.fonts")
local ScreenManager = require("sphere.screen.ScreenManager")
local tween = require("tween")

local PauseOverlay = {}

PauseOverlay.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")

PauseOverlay.baseDelay = 1

PauseOverlay.load = function(self)
	self.font = self.font or aquafonts.getFont(spherefonts.NotoSansRegular, 48)
	
	self.continueRectangle = Rectangle:new({
		x = 0, y = 0.99,
		w = 1, h = 0.01,
		cs = self.cs,
		color = {255, 255, 255, 255},
		mode = "fill"
	})
	self.continueRectangle:reload()
	
	self.continueButton = Theme.Button:new({
		text = "continue",
		interact = function() self:continue() end,
		
		x = 0, y = 0,
		w = 1, h = 1/3,
		cs = self.cs,
		backgroundColor = {0, 0, 0, 127},
		mode = "fill",
		limit = 1,
		textAlign = {x = "center", y = "center"},
		textColor = {255, 255, 255, 255},
		font = self.font,
	})
	self.continueButton:reload()
	
	self.retryButton = Theme.Button:new({
		text = "retry",
		interact = function() self:retry() end,
		
		x = 0, y = 1/3,
		w = 1, h = 1/3,
		cs = self.cs,
		backgroundColor = {0, 0, 0, 127},
		mode = "fill",
		limit = 1,
		textAlign = {x = "center", y = "center"},
		textColor = {255, 255, 255, 255},
		font = self.font,
	})
	self.retryButton:reload()
	
	self.menuButton = Theme.Button:new({
		text = "menu",
		interact = function() self:menu() end,
		
		x = 0, y = 2/3,
		w = 1, h = 1/3,
		cs = self.cs,
		backgroundColor = {0, 0, 0, 127},
		mode = "fill",
		limit = 1,
		textAlign = {x = "center", y = "center"},
		textColor = {255, 255, 255, 255},
		font = self.font,
	})
	self.menuButton:reload()
	
	self:stopContinue()
	self.paused = false
end

PauseOverlay.update = function(self, dt)
	if self.continueTween then
		self.continueTween:update(dt)
		self.continueRectangle.w = self.delay / self.baseDelay
		self.continueRectangle:reload()
	end
	
	if self.paused then
		self.continueButton:update()
		self.retryButton:update()
		self.menuButton:update()
		
		if self.delay == 0 then
			self.paused = false
			self:stopContinue()
			self:play()
		end
	end
end

PauseOverlay.draw = function(self)
	if self.paused then
		self.continueButton:draw()
		self.retryButton:draw()
		self.menuButton:draw()
		self.continueRectangle:draw()
	end
end

PauseOverlay.receive = function(self, event)
	if event.name == "resize" then
		self.continueButton:reload()
		self.retryButton:reload()
		self.menuButton:reload()
		self.continueRectangle:reload()
	end
	
	if event.name == "focus" and not self.paused and not event.args[1] then
		self:pause()
	end
	
	if self.paused then
		self.continueButton:receive(event)
		self.retryButton:receive(event)
		self.menuButton:receive(event)
	end
	
	local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "escape" and not shift then
			if self.continueTween then
				self:stopContinue()
				return
			end
			if self.engine.paused then
				self:continue()
			else
				self:pause()
			end
		elseif key == "escape" then
			self:menu()
		end
	end
end

PauseOverlay.stopContinue = function(self)
	self.continueTween = nil
	self.delay = self.baseDelay
	self.continueRectangle.w = 1
	self.continueRectangle:reload()
end

PauseOverlay.play = function(self)
	self.engine:play()
end

PauseOverlay.continue = function(self)
	self.continueTween = tween.new(1, self, {delay = 0}, "linear")
end

PauseOverlay.pause = function(self)
	self.engine:pause()
	self.paused = true
end

PauseOverlay.retry = function(self)
	local GameplayScreen = require("sphere.screen.GameplayScreen")
	GameplayScreen:unload()
	GameplayScreen:load()
	self.engine:play()
end

PauseOverlay.menu = function(self)
	local GameplayScreen = require("sphere.screen.GameplayScreen")
	ScreenManager:set(require("sphere.screen.ResultScreen"),
		function()
			ScreenManager:receive({
				name = "score",
				score = self.engine.score
			})
			ScreenManager:receive({
				name = "metadata",
				data = GameplayScreen.cacheData
			})
		end
	)
end

return PauseOverlay
