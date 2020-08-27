local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")
local RhythmView = require("sphere.views.RhythmView")
local NoteSkinView = require("sphere.views.NoteSkinView")
local DiscordGameplayView = require("sphere.views.DiscordGameplayView")
local PauseOverlay = require("sphere.ui.PauseOverlay")
local GUI = require("sphere.ui.GUI")
local BackgroundManager	= require("sphere.ui.BackgroundManager")

local GameplayView = Class:new()

GameplayView.construct = function(self)
	self.container = Container:new()
	self.noteSkinView = NoteSkinView:new()
	self.rhythmView = RhythmView:new()
	self.discordGameplayView = DiscordGameplayView:new()
	self.gui = GUI:new()
	self.pauseOverlay = PauseOverlay:new()
end

GameplayView.load = function(self)
	local container = self.container
	local noteSkinView = self.noteSkinView
	local rhythmView = self.rhythmView
	local discordGameplayView = self.discordGameplayView
	local gui = self.gui
	local pauseOverlay = self.pauseOverlay
	local configModel = self.configModel

	noteSkinView.noteSkin = self.noteSkin
	noteSkinView:load()

	rhythmView.rhythmModel = self.rhythmModel
	rhythmView.noteSkinView = noteSkinView
	rhythmView.container = container
	rhythmView:setBgaEnabled("video", configModel:get("gameplay.videobga"))
	rhythmView:setBgaEnabled("image", configModel:get("gameplay.imagebga"))
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

	local dim = 255 * (1 - (configModel:get("dim.gameplay") or 0))
	BackgroundManager:setColor({dim, dim, dim})
end

GameplayView.unload = function(self)
	self.rhythmView:unload()
	self.noteSkinView:unload()
	self.gui:unload()
	self.pauseOverlay.observable:remove(self.controller)
end

GameplayView.receive = function(self, event)
	self.noteSkinView:receive(event)
	self.rhythmView:receive(event)
	self.gui:receive(event)
	self.pauseOverlay:receive(event)
	self.discordGameplayView:receive(event)
end

GameplayView.update = function(self, dt)
	self.container:update()
	self.noteSkinView:update(dt)
	self.rhythmView:update(dt)
	self.gui:update()
	self.pauseOverlay:update(dt)
end

GameplayView.draw = function(self)
	self.container:draw()
	self.pauseOverlay:draw()
end

return GameplayView
