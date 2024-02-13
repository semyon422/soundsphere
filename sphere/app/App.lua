local class = require("class")

local DiscordModel = require("sphere.app.DiscordModel")
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
	self.screenshotModel = ScreenshotModel()
	self.windowModel = WindowModel()

	self.persistence = persistence

	self.mountController = MountController(persistence.configModel, persistence.cacheModel)
end

function App:load()
	self.discordModel:load()

	local configModel = self.persistence.configModel
	self.audioModel:load(configModel.configs.settings.audio.device)
	self.windowModel:load(configModel.configs.settings.graphics)
end

function App:unload()
	self.discordModel:unload()
end

function App:update()
	self.discordModel:update()
	self.windowModel:update()
end

---@param event table
function App:receive(event)
	self.windowModel:receive(event)

	local screenshot = self.persistence.configModel.configs.settings.input.screenshot
	local mountController = self.mountController

	if event.name == "filedropped" then
		mountController:filedropped(event[1])
	elseif event.name == "keypressed" and event[1] == screenshot.capture then
		local open = love.keyboard.isDown(screenshot.open)
		self.screenshotModel:capture(open)
	end
end

return App
