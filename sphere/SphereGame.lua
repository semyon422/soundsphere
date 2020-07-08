local aquaevent					= require("aqua.event")
local CoordinateManager			= require("aqua.graphics.CoordinateManager")
local ThreadPool				= require("aqua.thread.ThreadPool")
local GameConfig				= require("sphere.config.GameConfig")
local ScoreManager				= require("sphere.database.ScoreManager")
local CacheManager				= require("sphere.database.CacheManager")
local DiscordPresence			= require("sphere.discord.DiscordPresence")
local MountManager				= require("sphere.filesystem.MountManager")
local ScreenManager				= require("sphere.screen.ScreenManager")
local FadeTransition			= require("sphere.screen.FadeTransition")
local SelectScreen				= require("sphere.screen.select.SelectScreen")
local BackgroundManager			= require("sphere.ui.BackgroundManager")
local NotificationLine			= require("sphere.ui.NotificationLine")
local WindowManager				= require("sphere.window.WindowManager")
local FpsLimiter				= require("sphere.window.FpsLimiter")

local SphereGame = {}

SphereGame.run = function(self)
	self:init()
	self:load()
end

SphereGame.init = function(self)
	aquaevent:add(self)
end

SphereGame.load = function(self)
	WindowManager:load()
	GameConfig.observable:add(FpsLimiter)

	MountManager:mount()

	CacheManager:select()
	ScoreManager:select()
	GameConfig:read()

	DiscordPresence:load()

	ScreenManager:setTransition(FadeTransition)
	ScreenManager:set(SelectScreen)
end

SphereGame.unload = function(self)
	ScreenManager:unload()
	DiscordPresence:unload()
	GameConfig:write()
end

SphereGame.update = function(self, dt)
	ThreadPool:update()

	DiscordPresence:update()
	BackgroundManager:update(dt)
	NotificationLine:update()
	ScreenManager:update(dt)
end

SphereGame.draw = function(self)
	BackgroundManager:draw()
	ScreenManager:draw()
	NotificationLine:draw()
end

SphereGame.receive = function(self, event)
	if event.name == "update" then
		self:update(event.args[1])
	elseif event.name == "draw" then
		self:draw()
	elseif event.name == "quit" then
		self:unload()
		return os.exit()
	elseif event.name == "resize" then
		CoordinateManager:reload()
	end

	ScreenManager:receive(event)
	BackgroundManager:receive(event)
	NotificationLine:receive(event)
	WindowManager:receive(event)
end

return SphereGame
