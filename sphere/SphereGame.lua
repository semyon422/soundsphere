local Container = require("aqua.graphics.Container")
local ThreadPool = require("aqua.thread.ThreadPool")
local AudioManager = require("aqua.audio.AudioManager")
local Observer = require("aqua.util.Observer")
local aquaio = require("aqua.io")

local SelectionScreen = require("sphere.screen.SelectionScreen")
local ScreenManager = require("sphere.screen.ScreenManager")

local Cache = require("sphere.game.NoteChartManager.Cache")

local WindowManager = require("sphere.game.WindowManager")
local BackgroundManager = require("sphere.ui.BackgroundManager")
local NotificationLine = require("sphere.ui.NotificationLine")
local CLI = require("sphere.ui.CLI")

local SphereGame = {}

SphereGame.init = function(self)
	self.observer = Observer:new()
	self.observer.receive = function(_, ...) return self:receive(...) end
	self.globalUI = Container:new()
	
	BackgroundManager:init()
	NotificationLine:init()
	CLI:init()
end

SphereGame.run = function(self)
	self:init()
	self:load()
	aquaio:add(self.observer)
end

SphereGame.load = function(self)
	Cache:load()
	
	WindowManager:load()
	BackgroundManager:loadDrawableBackground("userdata/background.jpg")
	ScreenManager:set(SelectionScreen)
	NotificationLine:notify("welcome")
end

SphereGame.unload = function(self)
	ScreenManager:unload()
end

SphereGame.update = function(self, dt)
	ThreadPool:update()
	AudioManager:update()
	
	BackgroundManager:update(dt)
	NotificationLine:update()
	ScreenManager:update(dt)
	CLI:update()
end

SphereGame.draw = function(self)
	BackgroundManager:draw()
	ScreenManager:draw()
	NotificationLine:draw()
	CLI:draw()
end

SphereGame.receive = function(self, event)
	if event.name == "update" then
		self:update(event.args[1])
	elseif event.name == "draw" then
		self:draw()
	end
	
	if CLI.hidden or event.name == "resize" then
		ScreenManager:receive(event)
		BackgroundManager:receive(event)
		NotificationLine:receive(event)
		WindowManager:receive(event)
	end
	CLI:receive(event)
end

return SphereGame
