local aquaevent					= require("aqua.event")
local CoordinateManager			= require("aqua.graphics.CoordinateManager")
local ThreadPool				= require("aqua.thread.ThreadPool")
local MainLog					= require("sphere.MainLog")
local Config					= require("sphere.config.Config")
local Cache						= require("sphere.database.Cache")
local CacheDatabase				= require("sphere.database.CacheDatabase")
local NoteChartFactory			= require("sphere.database.NoteChartFactory")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")
local ScoreManager				= require("sphere.database.ScoreManager")
local ScoreDatabase				= require("sphere.database.ScoreDatabase")
local DiscordPresence			= require("sphere.discord.DiscordPresence")
local MountManager				= require("sphere.filesystem.MountManager")
local ScreenManager				= require("sphere.screen.ScreenManager")
local TransitionManager			= require("sphere.screen.TransitionManager")
local SelectScreen				= require("sphere.screen.select.SelectScreen")
local BackgroundManager			= require("sphere.ui.BackgroundManager")
local CLI						= require("sphere.ui.CLI")
local NotificationLine			= require("sphere.ui.NotificationLine")
local OverlayMenu				= require("sphere.ui.OverlayMenu")
local WindowManager				= require("sphere.window.WindowManager")

local SphereGame = {}

SphereGame.run = function(self)
	self:init()
	self:load()
end

SphereGame.init = function(self)
	Config:init()
	MainLog:init()
	
	CacheDatabase:init()
	ScoreDatabase:init()
	NoteChartFactory:init()
	NoteChartResourceLoader:init()
	
	ScreenManager:init()
	BackgroundManager:init()
	NotificationLine:init()
	CLI:init()
	OverlayMenu:init()
	
	aquaevent:add(self)
end

SphereGame.load = function(self)
	MountManager:mount()
	Cache:select()
	ScoreManager:load()
	Config:read()
	Config:write()
	
	Config.observable:add(self)
	aquaevent.fpslimit = Config.data.fps
	
	DiscordPresence:load()
	
	ScreenManager:set(SelectScreen)
	WindowManager:load()
end

SphereGame.unload = function(self)
	ScreenManager:unload()
	DiscordPresence:unload()
	Config:write()
end

SphereGame.update = function(self, dt)
	ThreadPool:update()
	
	DiscordPresence:update()
	BackgroundManager:update(dt)
	NotificationLine:update()
	ScreenManager:update(dt)
	CLI:update()
	OverlayMenu:update()
end

SphereGame.draw = function(self)
	BackgroundManager:draw()
	ScreenManager:draw()
	NotificationLine:draw()
	CLI:draw()
	OverlayMenu:draw()
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
	elseif event.name == "Config.set" then
		if event.key == "fps" then
			aquaevent.fpslimit = event.value
		end
	end
	
	local overlayHidden = OverlayMenu.hidden
	OverlayMenu:receive(event)
	if CLI.hidden and overlayHidden or event.name == "resize" then
		ScreenManager:receive(event)
		BackgroundManager:receive(event)
		NotificationLine:receive(event)
		WindowManager:receive(event)
	end
	CLI:receive(event)
end

return SphereGame
