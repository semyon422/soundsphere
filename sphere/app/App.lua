local class = require("class")

local ConfigModel = require("sphere.app.ConfigModel")
local DiscordModel = require("sphere.app.DiscordModel")
local MountModel = require("sphere.app.MountModel")
local WindowModel = require("sphere.app.WindowModel")
local ScreenshotModel = require("sphere.app.ScreenshotModel")
local AudioModel = require("sphere.app.AudioModel")

local MountController = require("sphere.app.MountController")
local FileFinder = require("sphere.app.FileFinder")
local dirs = require("sphere.app.dirs")

---@class sphere.App
---@operator call: sphere.App
local App = class()

function App:new()
	self.configModel = ConfigModel()
	self.audioModel = AudioModel()
	self.discordModel = DiscordModel()
	self.mountModel = MountModel()
	self.screenshotModel = ScreenshotModel()
	self.windowModel = WindowModel()
	self.fileFinder = FileFinder()

	-- self.mountController = MountController(self.configModel, self.mountModel)
	-- mountController = {
	-- 	"mountModel",
	-- 	"configModel",
	-- 	"cacheModel",
	-- },
end

function App:load()
	local configModel = self.configModel

	dirs.create()

	configModel:open("settings", true)
	configModel:open("select", true)
	configModel:open("modifier", true)
	configModel:open("input", true)
	configModel:open("mount", true)
	configModel:open("online", true)
	configModel:open("urls")
	configModel:open("judgements")
	configModel:open("filters")
	configModel:open("files")
	configModel:read()

	self.discordModel:load()

	self.audioModel:load(self.configModel.configs.settings.audio.device)
	self.mountModel:load(self.configModel.configs.mount)
	self.windowModel:load(self.configModel.configs.settings.graphics)
end

function App:unload()
	self.discordModel:unload()
	self.mountModel:unload()
	self.configModel:write()
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
