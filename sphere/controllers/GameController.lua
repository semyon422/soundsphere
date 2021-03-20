local aquaevent					= require("aqua.event")
local Class						= require("aqua.util.Class")
local CoordinateManager			= require("aqua.graphics.CoordinateManager")
local ThreadPool				= require("aqua.thread.ThreadPool")
local ConfigModel				= require("sphere.models.ConfigModel")
local ScoreModel				= require("sphere.models.ScoreModel")
local DiscordPresence			= require("sphere.discord.DiscordPresence")
local MountModel				= require("sphere.models.MountModel")
local MountController			= require("sphere.controllers.MountController")
local OnlineController			= require("sphere.controllers.OnlineController")
local ScreenManager				= require("sphere.screen.ScreenManager")
local FadeTransition			= require("sphere.screen.FadeTransition")
local SelectController			= require("sphere.controllers.SelectController")
local BackgroundManager			= require("sphere.ui.BackgroundManager")
local WindowManager				= require("sphere.window.WindowManager")
local FpsLimiter				= require("sphere.window.FpsLimiter")
local Screenshot				= require("sphere.window.Screenshot")
local NotificationView			= require("sphere.views.NotificationView")
local NotificationModel			= require("sphere.models.NotificationModel")
local ThemeModel				= require("sphere.models.ThemeModel")
local OnlineModel				= require("sphere.models.OnlineModel")
local CacheModel				= require("sphere.models.CacheModel")

local GameController = Class:new()

GameController.construct = function(self)
	self.configModel = ConfigModel:new()
	self.notificationModel = NotificationModel:new()
	self.notificationView = NotificationView:new()
	self.windowManager = WindowManager:new()
	self.mountModel = MountModel:new()
	self.mountController = MountController:new()
	self.onlineController = OnlineController:new()
	self.screenshot = Screenshot:new()
	self.themeModel = ThemeModel:new()
	self.scoreModel = ScoreModel:new()
	self.onlineModel = OnlineModel:new()
	self.cacheModel = CacheModel:new()
end

GameController.load = function(self)
	local notificationModel = self.notificationModel
	local notificationView = self.notificationView
	local configModel = self.configModel
	local windowManager = self.windowManager
	local mountModel = self.mountModel
	local mountController = self.mountController
	local onlineController = self.onlineController
	local screenshot = self.screenshot
	local themeModel = self.themeModel
	local scoreModel = self.scoreModel
	local onlineModel = self.onlineModel
	local cacheModel = self.cacheModel

	configModel:addConfig("settings_model", "userdata/settings_model.json", "sphere/models/ConfigModel/settings_model.json", "json")
	configModel:addConfig("settings", "userdata/settings.toml", "sphere/models/ConfigModel/settings.toml", "toml")
	configModel:addConfig("select", "userdata/select.toml", "sphere/models/ConfigModel/select.toml", "toml")
	configModel:addConfig("modifier", "userdata/modifier.json", "sphere/models/ConfigModel/modifier.json", "json")
	configModel:addConfig("noteskin", "userdata/noteskin.toml", "sphere/models/ConfigModel/noteskin.toml", "toml")
	configModel:addConfig("input", "userdata/input.json", "sphere/models/ConfigModel/input.json", "json")
	configModel:addConfig("mount", "userdata/mount.json", "sphere/models/ConfigModel/mount.json", "json")

	configModel:readConfig("settings_model")
	configModel:readConfig("settings")
	configModel:readConfig("select")
	configModel:readConfig("modifier")
	configModel:readConfig("noteskin")
	configModel:readConfig("input")
	configModel:readConfig("mount")

	onlineController.onlineModel = onlineModel
	onlineController.cacheModel = cacheModel
	onlineController.configModel = configModel

	themeModel.configModel = configModel
	themeModel:load()

	mountModel.configModel = configModel

	mountController.mountModel = mountModel
	mountModel:load()

	notificationModel.observable:add(notificationView)
	notificationView:load()

	windowManager:load()
	-- configModel.observable:add(FpsLimiter)
	-- configModel.observable:add(screenshot)

	scoreModel:select()
	-- configModel:read()

	onlineModel.configModel = configModel
	-- onlineModel.observable:add(onlineController)
	-- onlineModel:setHost(configModel:get("online.host"))
	-- onlineModel:setSession(configModel:get("online.session"))
	-- onlineModel:setUserId(configModel:get("online.userId"))
	onlineModel:load()

	onlineController:load()

	DiscordPresence:load()

	ScreenManager:setTransition(FadeTransition)

	local selectController = SelectController:new()
	selectController.notificationModel = notificationModel
	selectController.configModel = configModel
	selectController.mountModel = mountModel
	selectController.themeModel = themeModel
	selectController.scoreModel = scoreModel
	selectController.onlineModel = onlineModel
	selectController.cacheModel = cacheModel

	ScreenManager:set(selectController)
end

GameController.unload = function(self)
	ScreenManager:unload()
	DiscordPresence:unload()
	self.configModel:writeConfig("settings")
	self.configModel:writeConfig("select")
	self.configModel:writeConfig("modifier")
	self.configModel:writeConfig("noteskin")
	self.configModel:writeConfig("input")
	self.configModel:writeConfig("mount")
	self.mountModel:unload()
	self.onlineModel:unload()
end

GameController.update = function(self, dt)
	ThreadPool:update()

	DiscordPresence:update()
	BackgroundManager:update(dt)
	ScreenManager:update(dt)
	self.notificationView:update(dt)
	self.onlineController:update()
end

GameController.draw = function(self)
	BackgroundManager:draw()
	ScreenManager:draw()
	self.notificationView:draw()
end

GameController.receive = function(self, event)
	if event.name == "update" then
		self:update(event.args[1])
	elseif event.name == "draw" then
		self:draw()
	elseif event.name == "quit" then
		self:unload()
		aquaevent.quit()
	elseif event.name == "resize" then
		CoordinateManager:reload()
	end

	ScreenManager:receive(event)
	BackgroundManager:receive(event)
	self.windowManager:receive(event)
	self.screenshot:receive(event)
	self.mountController:receive(event)
	self.notificationView:receive(event)
end

return GameController
