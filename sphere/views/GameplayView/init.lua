local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")
local RhythmView = require("sphere.views.RhythmView")
local DiscordGameplayView = require("sphere.views.DiscordGameplayView")
local PauseOverlay = require("sphere.ui.PauseOverlay")
local GUI = require("sphere.ui.GUI")
local BackgroundManager	= require("sphere.ui.BackgroundManager")
local ScoreView	= require("sphere.views.GameplayView.ScoreView")
local ProgressView	= require("sphere.views.GameplayView.ProgressView")
local PointGraphView	= require("sphere.views.GameplayView.PointGraphView")
local ImageView	= require("sphere.views.GameplayView.ImageView")
local SequenceView	= require("sphere.views.SequenceView")

local GameplayView = Class:new()

GameplayView.construct = function(self)
	self.rhythmView = RhythmView:new()
	self.scoreView = ScoreView:new()
	self.progressView = ProgressView:new()
	self.pointGraphView = PointGraphView:new()
	self.imageView = ImageView:new()
	self.discordGameplayView = DiscordGameplayView:new()
	self.sequenceView = SequenceView:new()
	self.pauseOverlay = PauseOverlay:new()
end

GameplayView.load = function(self)
	local rhythmView = self.rhythmView
	local scoreView = self.scoreView
	local progressView = self.progressView
	local pointGraphView = self.pointGraphView
	local imageView = self.imageView
	local discordGameplayView = self.discordGameplayView
	local sequenceView = self.sequenceView
	local pauseOverlay = self.pauseOverlay
	local configModel = self.configModel

	local config = configModel:getConfig("settings")

	rhythmView.noteSkin = self.noteSkin
	rhythmView.rhythmModel = self.rhythmModel
	rhythmView:setBgaEnabled("video", config.gameplay.videobga)
	rhythmView:setBgaEnabled("image", config.gameplay.imagebga)

	scoreView.scoreSystem = self.scoreSystem
	scoreView.noteChartModel = self.noteChartModel

	progressView.scoreSystem = self.scoreSystem
	progressView.noteChartModel = self.noteChartModel

	pointGraphView.scoreSystem = self.scoreSystem
	pointGraphView.noteChartModel = self.noteChartModel

	imageView.root = self.noteSkin.directoryPath

	sequenceView:setView("RhythmView", rhythmView)
	sequenceView:setView("ScoreView", scoreView)
	sequenceView:setView("ProgressView", progressView)
	sequenceView:setView("PointGraphView", pointGraphView)
	sequenceView:setView("ImageView", imageView)
	sequenceView:setSequenceConfig(self.noteSkin.playField)
	sequenceView:load()

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
	self.sequenceView:unload()
	self.pauseOverlay.observable:remove(self.controller)
end

GameplayView.receive = function(self, event)
	self.sequenceView:receive(event)
	self.pauseOverlay:receive(event)
	self.discordGameplayView:receive(event)
end

GameplayView.update = function(self, dt)
	self.sequenceView:update(dt)
	self.pauseOverlay:update(dt)
end

GameplayView.draw = function(self)
	self.sequenceView:draw()
	self.pauseOverlay:draw()
end

return GameplayView
