local viewspackage = (...):match("^(.-%.views%.)")

local RhythmView = require("sphere.views.RhythmView")
local GameplayViewConfig = require("sphere.views.GameplayView.GameplayViewConfig")
local DiscordGameplayView = require("sphere.views.DiscordGameplayView")
local PauseOverlay = require("sphere.views.GameplayView.PauseOverlay")
local ValueView	= require("sphere.views.GameplayView.ValueView")
local ProgressView	= require("sphere.views.GameplayView.ProgressView")
local PointGraphView = require("sphere.views.GameplayView.PointGraphView")
local ImageView	= require("sphere.views.GameplayView.ImageView")
local InputImageView	= require("sphere.views.GameplayView.InputImageView")
local GameplayNavigator	= require("sphere.views.GameplayView.GameplayNavigator")
local SequenceView = require(viewspackage .. "SequenceView")
local ScreenView = require(viewspackage .. "ScreenView")

local GameplayView = ScreenView:new()

GameplayView.construct = function(self)
	self.viewConfig = GameplayViewConfig
	self.playfieldView = SequenceView:new()
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
	local playfieldView = self.playfieldView
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
	progressView.rhythmModel = self.rhythmModel
	progressView.noteChartModel = self.noteChartModel

	pointGraphView.scoreSystem = self.scoreSystem
	pointGraphView.noteChartModel = self.noteChartModel

	imageView.root = self.noteSkin.directoryPath
	inputImageView.root = self.noteSkin.directoryPath

	playfieldView:setSequenceConfig(self.noteSkin.playField)
	playfieldView:setView("RhythmView", rhythmView)
	playfieldView:setView("ValueView", valueView)
	playfieldView:setView("ProgressView", progressView)
	playfieldView:setView("PointGraphView", pointGraphView)
	playfieldView:setView("ImageView", imageView)
	playfieldView:setView("InputImageView", inputImageView)
	playfieldView:load()

	sequenceView:setView("PlayfieldView", playfieldView)

	discordGameplayView.rhythmModel = self.rhythmModel
	discordGameplayView.noteChartModel = self.noteChartModel

	ScreenView.load(self)
end

return GameplayView
