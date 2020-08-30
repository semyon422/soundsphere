
local Class						= require("aqua.util.Class")
local CoordinateManager			= require("aqua.graphics.CoordinateManager")
local ThreadPool				= require("aqua.thread.ThreadPool")
local ConfigModel				= require("sphere.models.ConfigModel")
local ScoreManager				= require("sphere.database.ScoreManager")
local DiscordPresence			= require("sphere.discord.DiscordPresence")
local MountModel				= require("sphere.models.MountModel")
local MountController			= require("sphere.controllers.MountController")
local ScreenManager				= require("sphere.screen.ScreenManager")
local FadeTransition			= require("sphere.screen.FadeTransition")
local SelectController			= require("sphere.controllers.SelectController")
local BackgroundManager			= require("sphere.ui.BackgroundManager")
local WindowManager				= require("sphere.window.WindowManager")
local FpsLimiter				= require("sphere.window.FpsLimiter")
local Screenshot				= require("sphere.window.Screenshot")
local UserView					= require("sphere.views.UserView")
local NotificationView			= require("sphere.views.NotificationView")
local NotificationModel			= require("sphere.models.NotificationModel")

local GameController = Class:new()

GameController.construct = function(self)
	self.globalView = UserView:new()
	self.configModel = ConfigModel:new()
	self.notificationModel = NotificationModel:new()
	self.notificationView = NotificationView:new()
	self.windowManager = WindowManager:new()
	self.mountModel = MountModel:new()
	self.mountController = MountController:new()
	self.screenshot = Screenshot:new()
end

GameController.load = function(self)
	local notificationModel = self.notificationModel
	local notificationView = self.notificationView
	local configModel = self.configModel
	local globalView = self.globalView
	local windowManager = self.windowManager
	local mountModel = self.mountModel
	local mountController = self.mountController
	local screenshot = self.screenshot

	mountController.mountModel = mountModel
	mountModel:load()

	globalView:setPath("sphere/views/global.lua")
	notificationModel.observable:add(globalView)

	notificationModel.observable:add(notificationView)
	notificationView:load()

	configModel:setPath("userdata/config.json")

	windowManager:load()
	configModel.observable:add(FpsLimiter)
	configModel.observable:add(screenshot)

	ScoreManager:select()
	configModel:read()

	DiscordPresence:load()

	globalView:load()

	ScreenManager:setTransition(FadeTransition)

	local selectController = SelectController:new()
	selectController.notificationModel = notificationModel
	selectController.configModel = configModel
	selectController.mountModel = mountModel

	ScreenManager:set(selectController)
end

GameController.unload = function(self)
	self.globalView:unload()
	ScreenManager:unload()
	DiscordPresence:unload()
	self.configModel:write()
	self.mountModel:unload()
end

GameController.update = function(self, dt)
	ThreadPool:update()

	DiscordPresence:update()
	BackgroundManager:update(dt)
	ScreenManager:update(dt)
	self.globalView:update(dt)
	self.notificationView:update(dt)
end

GameController.draw = function(self)
	BackgroundManager:draw()
	ScreenManager:draw()
	self.globalView:draw()
	self.notificationView:draw()
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
	self.mountController:receive(event)
	self.notificationView:receive(event)
end

return GameController
