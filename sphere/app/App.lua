local class = require("class")

local DiscordModel = require("sphere.app.DiscordModel")
local MountModel = require("sphere.app.MountModel")
local WindowModel = require("sphere.app.WindowModel")
local ScreenshotModel = require("sphere.app.ScreenshotModel")
local AudioModel = require("sphere.app.AudioModel")

local MountController = require("sphere.app.MountController")

---@class sphere.App
---@operator call: sphere.App
local App = class()

---@param persistence sphere.Persistence
function App:new(persistence)
	self.audioModel = AudioModel()
	self.discordModel = DiscordModel()
	self.mountModel = MountModel()
	self.screenshotModel = ScreenshotModel()
	self.windowModel = WindowModel()

	self.persistence = persistence

	-- self.mountController = MountController(self.configModel, self.mountModel)
	-- mountController = {
	-- 	"mountModel",
	-- 	"configModel",
	-- 	"cacheModel",
	-- },
end

function App:load()
	self.discordModel:load()

	local configModel = self.persistence.configModel
	self.audioModel:load(configModel.configs.settings.audio.device)
	self.mountModel:load(configModel.configs.mount)
	self.windowModel:load(configModel.configs.settings.graphics)
end

function App:unload()
	self.discordModel:unload()
	self.mountModel:unload()
end

function App:update()
	self.discordModel:update()
	self.windowModel:update()
end

---@param event table
function App:receive(event)
	self.windowModel:receive(event)
	-- self.screenshotModel:receive(event)  -- fix screenshot capture
	-- self.mountController:receive(event)  -- fix folder drop
end

return App
