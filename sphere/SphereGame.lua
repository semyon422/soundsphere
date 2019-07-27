local Container = require("aqua.graphics.Container")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ThreadPool = require("aqua.thread.ThreadPool")
local Observer = require("aqua.util.Observer")
local aquaio = require("aqua.io")

local SelectionScreen = require("sphere.screen.SelectionScreen")
local ScreenManager = require("sphere.screen.ScreenManager")
local TransitionManager = require("sphere.screen.TransitionManager")

local Cache = require("sphere.game.NoteChartManager.Cache")
local ScoreManager = require("sphere.game.ScoreManager")
local Config = require("sphere.game.Config")

local DiscordPresence = require("sphere.game.DiscordPresence")
local MountManager = require("sphere.game.MountManager")
local WindowManager = require("sphere.game.WindowManager")
local BackgroundManager = require("sphere.ui.BackgroundManager")
local NotificationLine = require("sphere.ui.NotificationLine")
local GameUI = require("sphere.ui.GameUI")
local CLI = require("sphere.ui.CLI")

local SphereGame = {}

SphereGame.init = function(self)
	self.observer = Observer:new()
	self.observer.receive = function(_, ...) return self:receive(...) end
	self.globalUI = Container:new()
	GameUI:init()
	
	BackgroundManager:init()
	NotificationLine:init()
	CLI:init()
end

SphereGame.run = function(self)
	self:init()
	aquaio:add(self.observer)
	MountManager:mount()
	self:load()
	WindowManager:load()
end

SphereGame.load = function(self)
	Cache:select()
	ScoreManager:load()
	Config:read()
	Config:write()
	
	DiscordPresence:load()
	
	aquaio.fpslimit = Config.data.fps
	
	BackgroundManager:loadDrawableBackground("userdata/background.jpg")
	ScreenManager:set(SelectionScreen)
	NotificationLine:notify("welcome")
end

SphereGame.unload = function(self)
	ScreenManager:unload()
	DiscordPresence:unload()
	-- MountManager:unmount()
	Config:write()
end

SphereGame.update = function(self, dt)
	ThreadPool:update()
	
	DiscordPresence:update()
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
	elseif event.name == "quit" then
		self:unload()
		os.exit()
	elseif event.name == "resize" then
		CoordinateManager:reload()
	end
	
	if CLI.hidden or event.name == "resize" then
		GameUI:receive(event)
		ScreenManager:receive(event)
		BackgroundManager:receive(event)
		NotificationLine:receive(event)
		WindowManager:receive(event)
	end
	CLI:receive(event)
end

return SphereGame
