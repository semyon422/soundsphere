local CS = require("aqua.graphics.CS")
local aquafonts = require("aqua.assets.fonts")
local Theme = require("aqua.ui.Theme")
local spherefonts = require("sphere.assets.fonts")
local ScreenManager = require("sphere.screen.ScreenManager")

local PauseOverlay = {}

PauseOverlay.cs = CS:new({
	bx = 0, by = 0, rx = 0, ry = 0,
	binding = "all",
	baseOne = 768
})

PauseOverlay.load = function(self)
	self.cs:reload()
	
	self.font = self.font or aquafonts.getFont(spherefonts.NotoSansRegular, 48)
	
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
end

PauseOverlay.update = function(self)
	if self.paused then
		self.continueButton:update()
		self.retryButton:update()
		self.menuButton:update()
	end
end

PauseOverlay.draw = function(self)
	if self.paused then
		self.continueButton:draw()
		self.retryButton:draw()
		self.menuButton:draw()
	end
end

PauseOverlay.receive = function(self, event)
	if event.name == "resize" then
		self.cs:reload()
		self.continueButton:reload()
		self.retryButton:reload()
		self.menuButton:reload()
	end
	
	if self.paused then
		self.continueButton:receive(event)
		self.retryButton:receive(event)
		self.menuButton:receive(event)
	end
end

PauseOverlay.continue = function(self)
	self:pause()
end

PauseOverlay.retry = function(self)
	local GameplayScreen = require("sphere.screen.GameplayScreen")
	GameplayScreen:unload()
	GameplayScreen:load()
	self.engine:play()
end

PauseOverlay.menu = function(self)
	ScreenManager:set(require("sphere.screen.ResultScreen"),
		function()
			ScreenManager:receive({
				name = "score",
				score = self.engine.score
			})
			ScreenManager:receive({
				name = "metadata",
				data = self.cacheData
			})
		end
	)
end

PauseOverlay.pause = function(self)
	if self.engine.paused then
		self.engine:play()
	else
		self.engine:pause()
	end
	self.paused = self.engine.paused
end

return PauseOverlay
