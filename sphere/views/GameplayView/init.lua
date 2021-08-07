local viewspackage = (...):match("^(.-%.views%.)")

local RhythmView = require("sphere.views.RhythmView")
local DiscordGameplayView = require("sphere.views.DiscordGameplayView")
local PauseOverlay = require("sphere.views.GameplayView.PauseOverlay")
local ValueView	= require("sphere.views.GameplayView.ValueView")
local ProgressView	= require("sphere.views.GameplayView.ProgressView")
local PointGraphView = require("sphere.views.GameplayView.PointGraphView")
local ImageView	= require("sphere.views.GameplayView.ImageView")
local InputImageView	= require("sphere.views.GameplayView.InputImageView")
local GameplayNavigator	= require("sphere.views.GameplayView.GameplayNavigator")
local ScreenView = require(viewspackage .. "ScreenView")

local GameplayView = ScreenView:new()

GameplayView.construct = function(self)
	self.navigator = GameplayNavigator:new()
	self.rhythmView = RhythmView:new()
	self.valueView = ValueView:new()
	self.progressView = ProgressView:new()
	self.pointGraphView = PointGraphView:new()
	self.imageView = ImageView:new()
	self.inputImageView = InputImageView:new()
	self.discordGameplayView = DiscordGameplayView:new()
	self.pauseOverlay = PauseOverlay:new()
end

GameplayView.load = function(self)
	local rhythmView = self.rhythmView
	local valueView = self.valueView
	local progressView = self.progressView
	local pointGraphView = self.pointGraphView
	local imageView = self.imageView
	local inputImageView = self.inputImageView
	local discordGameplayView = self.discordGameplayView
	local sequenceView = self.sequenceView
	local pauseOverlay = self.pauseOverlay
	local configModel = self.configModel
	local modifierModel = self.modifierModel

	local config = configModel:getConfig("settings")

	self.navigator.rhythmModel = self.rhythmModel

	rhythmView.noteSkin = self.noteSkin
	rhythmView.rhythmModel = self.rhythmModel
	rhythmView:setBgaEnabled("video", config.general.videobga)
	rhythmView:setBgaEnabled("image", config.general.imagebga)

	valueView.scoreSystem = self.scoreSystem
	valueView.noteChartDataEntry = self.noteChartModel.noteChartDataEntry
	valueView.modifierString = modifierModel:getString()

	progressView.scoreSystem = self.scoreSystem
	progressView.noteChartModel = self.noteChartModel

	pointGraphView.scoreSystem = self.scoreSystem
	pointGraphView.noteChartModel = self.noteChartModel

	imageView.root = self.noteSkin.directoryPath
	inputImageView.root = self.noteSkin.directoryPath

	self.viewConfig = self.noteSkin.playField
	sequenceView:setView("RhythmView", rhythmView)
	sequenceView:setView("ValueView", valueView)
	sequenceView:setView("ProgressView", progressView)
	sequenceView:setView("PointGraphView", pointGraphView)
	sequenceView:setView("ImageView", imageView)
	sequenceView:setView("InputImageView", inputImageView)
	-- sequenceView:setSequenceConfig(self.noteSkin.playField)
	-- sequenceView:load()

	-- pauseOverlay:load()
	-- pauseOverlay.rhythmModel = self.rhythmModel
	-- pauseOverlay.configModel = configModel
	-- pauseOverlay.observable:add(self.controller)

	discordGameplayView.rhythmModel = self.rhythmModel
	discordGameplayView.noteChartModel = self.noteChartModel

	ScreenView.load(self)
end

return GameplayView
