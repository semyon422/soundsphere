
local Class						= require("aqua.util.Class")
local CoordinateManager			= require("aqua.graphics.CoordinateManager")
local ThreadPool				= require("aqua.thread.ThreadPool")
local ConfigModel				= require("sphere.models.ConfigModel")
local ScoreManager				= require("sphere.database.ScoreManager")
local DiscordPresence			= require("sphere.discord.DiscordPresence")
local MountManager				= require("sphere.filesystem.MountManager")
local ScreenManager				= require("sphere.screen.ScreenManager")
local FadeTransition			= require("sphere.screen.FadeTransition")
local SelectController			= require("sphere.controllers.SelectController")
local BackgroundManager			= require("sphere.ui.BackgroundManager")
local WindowManager				= require("sphere.window.WindowManager")
local FpsLimiter				= require("sphere.window.FpsLimiter")
local Screenshot				= require("sphere.window.Screenshot")
local UserView					= require("sphere.views.UserView")
local NotificationModel			= require("sphere.models.NotificationModel")

local GameController = Class:new()

GameController.construct = function(self)
	self.globalView = UserView:new()
	self.configModel = ConfigModel:new()
	self.notificationModel = NotificationModel:new()
	self.windowManager = WindowManager:new()
	self.mountManager = MountManager:new()
	self.screenshot = Screenshot:new()
end

GameController.load = function(self)
	local notificationModel = self.notificationModel
	local configModel = self.configModel
	local globalView = self.globalView
	local windowManager = self.windowManager
	local mountManager = self.mountManager
	local screenshot = self.screenshot

	globalView:setPath("sphere/views/global.lua")
	notificationModel.observable:add(globalView)

	configModel:setPath("userdata/config.json")

	windowManager:load()
	configModel.observable:add(FpsLimiter)
	configModel.observable:add(screenshot)

	mountManager:mount()

	ScoreManager:select()
	print("READ")
	configModel:read()

	DiscordPresence:load()

	globalView:load()

	ScreenManager:setTransition(FadeTransition)

	local selectController = SelectController:new()
	selectController.notificationModel = notificationModel
	selectController.configModel = configModel

	ScreenManager:set(selectController)
end

GameController.unload = function(self)
	self.globalView:unload()
	ScreenManager:unload()
	DiscordPresence:unload()
	self.configModel:write()
end

GameController.update = function(self, dt)
	ThreadPool:update()

	DiscordPresence:update()
	BackgroundManager:update(dt)
	ScreenManager:update(dt)
	self.globalView:update(dt)
end

GameController.draw = function(self)
	BackgroundManager:draw()
	ScreenManager:draw()
	self.globalView:draw()
end

GameController.receive = function(self, event)
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
	self.windowManager:receive(event)
	self.globalView:receive(event)
	self.screenshot:receive(event)
end

return GameController
