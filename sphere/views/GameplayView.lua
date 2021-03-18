local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")
local RhythmView = require("sphere.views.RhythmView")
local DiscordGameplayView = require("sphere.views.DiscordGameplayView")
local PauseOverlay = require("sphere.ui.PauseOverlay")
local GUI = require("sphere.ui.GUI")
local BackgroundManager	= require("sphere.ui.BackgroundManager")

local GameplayView = Class:new()

GameplayView.construct = function(self)
	self.container = Container:new()
	self.rhythmView = RhythmView:new()
	self.discordGameplayView = DiscordGameplayView:new()
	self.gui = GUI:new()
	self.pauseOverlay = PauseOverlay:new()
end

GameplayView.load = function(self)
	local container = self.container
	local rhythmView = self.rhythmView
	local discordGameplayView = self.discordGameplayView
	local gui = self.gui
	local pauseOverlay = self.pauseOverlay
	local configModel = self.configModel

	local config = configModel:getConfig("settings")

	rhythmView.noteSkin = self.noteSkin
	rhythmView.rhythmModel = self.rhythmModel
	rhythmView.container = container
	rhythmView:setBgaEnabled("video", config.gameplay.videobga)
	rhythmView:setBgaEnabled("image", config.gameplay.imagebga)
	rhythmView:load()

	gui.container = container
	gui.root = self.noteSkin.directoryPath
	gui.scoreSystem = self.scoreSystem
	gui.noteChartModel = self.noteChartModel
	gui:loadTable(self.noteSkin.playField)

	pauseOverlay:load()
	pauseOverlay.rhythmModel = self.rhythmModel
	pauseOverlay.configModel = configModel
	pauseOverlay.observable:add(self.controller)

	discordGameplayView.rhythmModel = self.rhythmModel
	discordGameplayView.noteChartModel = self.noteChartModel

	local dim = 255 * (1 - (config.dim.gameplay or 0))
	BackgroundManager:setColor({dim, dim, dim})
end

GameplayView.unload = function(self)
	self.rhythmView:unload()
	self.gui:unload()
	self.pauseOverlay.observable:remove(self.controller)
end

GameplayView.receive = function(self, event)
	self.rhythmView:receive(event)
	self.gui:receive(event)
	self.pauseOverlay:receive(event)
	self.discordGameplayView:receive(event)
end

GameplayView.update = function(self, dt)
	self.container:update()
	self.rhythmView:update(dt)
	self.gui:update()
	self.pauseOverlay:update(dt)
end

GameplayView.draw = function(self)
	self.container:draw()
	self.pauseOverlay:draw()
end

return GameplayView
