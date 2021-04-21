local Class = require("aqua.util.Class")
local RhythmView = require("sphere.views.RhythmView")
local DiscordGameplayView = require("sphere.views.DiscordGameplayView")
local PauseOverlay = require("sphere.views.GameplayView.PauseOverlay")
local ValueView	= require("sphere.views.GameplayView.ValueView")
local ProgressView	= require("sphere.views.GameplayView.ProgressView")
local PointGraphView	= require("sphere.views.GameplayView.PointGraphView")
local ImageView	= require("sphere.views.GameplayView.ImageView")
local SequenceView	= require("sphere.views.SequenceView")

local GameplayView = Class:new()

GameplayView.construct = function(self)
	self.rhythmView = RhythmView:new()
	self.valueView = ValueView:new()
	self.progressView = ProgressView:new()
	self.pointGraphView = PointGraphView:new()
	self.imageView = ImageView:new()
	self.discordGameplayView = DiscordGameplayView:new()
	self.sequenceView = SequenceView:new()
	self.pauseOverlay = PauseOverlay:new()
end

GameplayView.load = function(self)
	local rhythmView = self.rhythmView
	local valueView = self.valueView
	local progressView = self.progressView
	local pointGraphView = self.pointGraphView
	local imageView = self.imageView
	local discordGameplayView = self.discordGameplayView
	local sequenceView = self.sequenceView
	local pauseOverlay = self.pauseOverlay
	local configModel = self.configModel
	local modifierModel = self.modifierModel

	local config = configModel:getConfig("settings")

	rhythmView.noteSkin = self.noteSkin
	rhythmView.rhythmModel = self.rhythmModel
	rhythmView:setBgaEnabled("video", config.gameplay.videobga)
	rhythmView:setBgaEnabled("image", config.gameplay.imagebga)

	valueView.scoreSystem = self.scoreSystem
	valueView.noteChartDataEntry = self.noteChartModel.noteChartDataEntry
	valueView.modifierString = modifierModel:getString()

	progressView.scoreSystem = self.scoreSystem
	progressView.noteChartModel = self.noteChartModel

	pointGraphView.scoreSystem = self.scoreSystem
	pointGraphView.noteChartModel = self.noteChartModel

	imageView.root = self.noteSkin.directoryPath

	sequenceView:setView("RhythmView", rhythmView)
	sequenceView:setView("ValueView", valueView)
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
