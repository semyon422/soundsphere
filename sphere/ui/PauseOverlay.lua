local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local aquafonts			= require("aqua.assets.fonts")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Rectangle			= require("aqua.graphics.Rectangle")
local Theme				= require("aqua.ui.Theme")
local spherefonts		= require("sphere.assets.fonts")
local tween				= require("tween")

local PauseOverlay = Class:new()

PauseOverlay.load = function(self)
	self.observable = Observable:new()
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
		w = 1, h = 1/3,
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
		interact = function() self:restart() end,

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
	
	self:reload()

	self:resetProgress()
	self.paused = false
end

PauseOverlay.reload = function(self)
	self.progressRectangle:reload()
	self.continueButton:reload()
	self.retryButton:reload()
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
		self.menuButton:draw()
	end
	self.progressRectangle:draw()
end

PauseOverlay.receive = function(self, event)
	if event.name == "resize" then
		self:reload()
	end

	if event.name == "focus" and not self.paused and not event.args[1] and not self.autoplay then
		self:pause()
	end

	if self.paused then
		self.continueButton:receive(event)
		self.retryButton:receive(event)
		self.menuButton:receive(event)
	end

	local quickRestartKey = self.configModel:get("gameplay.quickRestart")
	local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "escape" and not shift then
			if self.progressTween then
				self:resetProgress()
				return
			end
			if self.rhythmModel.timeEngine.timeRate == 0 then
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
	self.observable:send({
		name = "play"
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
	self.observable:send({
		name = "pause"
	})
	self.paused = true
end

PauseOverlay.restart = function(self)
	self.observable:send({
		name = "restart"
	})
end

PauseOverlay.menu = function(self)
	self.observable:send({
		name = "quit"
	})
end

return PauseOverlay
