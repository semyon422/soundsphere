local aquafonts			= require("aqua.assets.fonts")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Rectangle			= require("aqua.graphics.Rectangle")
local Theme				= require("aqua.ui.Theme")
local spherefonts		= require("sphere.assets.fonts")
local Config			= require("sphere.config.Config")
local DiscordPresence	= require("sphere.discord.DiscordPresence")
local ScreenManager		= require("sphere.screen.ScreenManager")
local ReplayManager		= require("sphere.screen.gameplay.ReplayManager")
local InputManager		= require("sphere.screen.gameplay.InputManager")
local tween				= require("tween")

local PauseOverlay = {}

PauseOverlay.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
	self.font = aquafonts.getFont(spherefonts.NotoSansRegular, 48)
	
	self.progressRectangle = Rectangle:new({
		x = 0, y = 0.99,
		w = 1, h = 0.01,
		cs = self.cs,
		color = {255, 255, 255, 255},
		mode = "fill"
	})
	
	self.continueButton = Theme.Button:new({
		text = "continue",
		interact = function() self:beginPlay() end,
		
		x = 0, y = 0,
		w = 1, h = 1/4,
		cs = self.cs,
		backgroundColor = {0, 0, 0, 127},
		mode = "fill",
		limit = 1,
		textAlign = {x = "center", y = "center"},
		textColor = {255, 255, 255, 255},
		font = self.font,
	})
	
	self.retryButton = Theme.Button:new({
		text = "retry",
		interact = function()
			InputManager:setMode("external")
			ReplayManager:setMode("record")
			self:restart()
		end,
		
		x = 0, y = 1/4,
		w = 1, h = 1/4,
		cs = self.cs,
		backgroundColor = {0, 0, 0, 127},
		mode = "fill",
		limit = 1,
		textAlign = {x = "center", y = "center"},
		textColor = {255, 255, 255, 255},
		font = self.font,
	})
	
	self.replayButton = Theme.Button:new({
		text = "replay",
		interact = function()
			InputManager:setMode("internal")
			ReplayManager:setMode("replay")

			-- local GameplayScreen = require("sphere.screen.gameplay.GameplayScreen")

			-- local FastPlay = require("sphere.screen.gameplay.ReplayManager.FastPlay")
			-- FastPlay.replay = ReplayManager.replay
			-- FastPlay.noteChartEntry = GameplayScreen.noteChartEntry
			-- FastPlay.noteChartDataEntry = GameplayScreen.noteChartDataEntry
			-- FastPlay:play()

			self:restart()
		end,
		
		x = 0, y = 1/2,
		w = 1, h = 1/4,
		cs = self.cs,
		backgroundColor = {0, 0, 0, 127},
		mode = "fill",
		limit = 1,
		textAlign = {x = "center", y = "center"},
		textColor = {255, 255, 255, 255},
		font = self.font,
	})
	
	self.menuButton = Theme.Button:new({
		text = "menu",
		interact = function()
			InputManager:setMode("external")
			ReplayManager:setMode("record")
			self:menu()
		end,
		
		x = 0, y = 3/4,
		w = 1, h = 1/4,
		cs = self.cs,
		backgroundColor = {0, 0, 0, 127},
		mode = "fill",
		limit = 1,
		textAlign = {x = "center", y = "center"},
		textColor = {255, 255, 255, 255},
		font = self.font,
	})
end

PauseOverlay.load = function(self)
	self:reload()
	
	self:resetProgress()
	self.paused = false
end

PauseOverlay.reload = function(self)
	self.progressRectangle:reload()
	self.continueButton:reload()
	self.retryButton:reload()
	self.replayButton:reload()
	self.menuButton:reload()
end

PauseOverlay.update = function(self, dt)
	if self.progressTween then
		self.progressTween:update(dt)
		self.progressRectangle.w = self.delay / self.baseDelay
		self.progressRectangle:reload()
	end
	
	if self.paused then
		self.continueButton:update()
		self.retryButton:update()
		self.replayButton:update()
		self.menuButton:update()
	end
	
	if self.action == "play" and self.delay / self.baseDelay == 0 then
		self:resetProgress()
		self:play()
	elseif self.action == "restart" and self.delay / self.baseDelay == 1 then
		self:resetProgress()
		self:restart()
	end
end

PauseOverlay.draw = function(self)
	if self.paused then
		self.continueButton:draw()
		self.retryButton:draw()
		self.replayButton:draw()
		self.menuButton:draw()
	end
	self.progressRectangle:draw()
end

PauseOverlay.receive = function(self, event)
	if event.name == "resize" then
		self:reload()
	end
	
	if event.name == "focus" and not self.paused and not event.args[1] and not self.logicEngine.autoplay then
		self:pause()
	end
	
	if self.paused then
		self.continueButton:receive(event)
		self.retryButton:receive(event)
		self.replayButton:receive(event)
		self.menuButton:receive(event)
	end
	
	local quickRestartKey = Config:get("gameplay.quickRestart")
	local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "escape" and not shift then
			if self.progressTween then
				self:resetProgress()
				return
			end
			if self.timeEngine.timeRate == 0 then
				self:beginPlay()
			else
				self:pause()
			end
		elseif key == "escape" then
			self:menu()
		elseif key == quickRestartKey then
			self:beginRestart()
		end
	elseif event.name == "keyreleased" then
		local key = event.args[1]
		if key == quickRestartKey then
			self:resetProgress()
		end
	end
end

PauseOverlay.resetProgress = function(self)
	self.action = nil
	self.progressTween = nil
	self.delay = 0
	self.progressRectangle.w = 0
	self.progressRectangle:reload()
end

PauseOverlay.play = function(self)
	self.paused = false
	self.timeEngine:setTimeRate(self.timeEngine:getBaseTimeRate())
	
	local length = math.min(self.noteChartDataEntry.length, 3600 * 24)
	DiscordPresence:setPresence({
		state = "Playing",
		details = ("%s - %s [%s]"):format(self.noteChartDataEntry.artist, self.noteChartDataEntry.title, self.noteChartDataEntry.name),
		endTimestamp = math.floor(os.time() + (length - self.timeEngine.currentTime) / self.timeEngine.timeRate)
	})
end

PauseOverlay.beginPlay = function(self)
	self.action = "play"
	self.delay = 0.5
	self.baseDelay = 0.5
	self.progressTween = tween.new(self.baseDelay, self, {delay = 0}, "linear")
end

PauseOverlay.beginRestart = function(self)
	self.action = "restart"
	self.delay = 0
	self.baseDelay = 0.5
	self.progressTween = tween.new(self.baseDelay, self, {delay = self.baseDelay}, "linear")
end

PauseOverlay.pause = function(self)
	self.timeEngine:setTimeRate(0)
	self.paused = true
	
	DiscordPresence:setPresence({
		state = "Playing (paused)",
		details = ("%s - %s [%s]"):format(self.noteChartDataEntry.artist, self.noteChartDataEntry.title, self.noteChartDataEntry.name)
	})
end

PauseOverlay.restart = function(self)
	local GameplayScreen = require("sphere.screen.gameplay.GameplayScreen")
	GameplayScreen:unload()
	GameplayScreen:load()
	self.timeEngine:setTimeRate(self.timeEngine:getBaseTimeRate())
end

PauseOverlay.menu = function(self)
	local GameplayScreen = require("sphere.screen.gameplay.GameplayScreen")
	ScreenManager:set(require("sphere.screen.result.ResultScreen"),
		function()
			ScreenManager:receive({
				name = "scoreSystem",
				scoreSystem = self.scoreSystem,
				noteChart = self.noteChart,
				noteChartEntry = GameplayScreen.noteChartEntry,
				noteChartDataEntry = GameplayScreen.noteChartDataEntry
			})
		end
	)
	
	DiscordPresence:setPresence({})
end

return PauseOverlay
