local viewspackage = (...):match("^(.-%.views%.)")

local RhythmView = require("sphere.views.RhythmView")
local GameplayViewConfig = require("sphere.views.GameplayView.GameplayViewConfig")
local DiscordGameplayView = require("sphere.views.DiscordGameplayView")
local ProgressView	= require("sphere.views.GameplayView.ProgressView")
local PointGraphView = require("sphere.views.GameplayView.PointGraphView")
local InputView	= require("sphere.views.GameplayView.InputView")
local InputAnimationView	= require("sphere.views.GameplayView.InputAnimationView")
local GameplayNavigator	= require("sphere.views.GameplayView.GameplayNavigator")
local JudgementView	= require("sphere.views.GameplayView.JudgementView")
local SequenceView = require(viewspackage .. "SequenceView")
local ScreenView = require(viewspackage .. "ScreenView")

local GameplayView = ScreenView:new({construct = false})

GameplayView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = GameplayViewConfig
	self.playfieldView = SequenceView:new()
	self.navigator = GameplayNavigator:new()
	self.rhythmView = RhythmView:new()
	self.progressView = ProgressView:new()
	self.menuProgressView = ProgressView:new()
	self.pointGraphView = PointGraphView:new()
	self.inputView = InputView:new()
	self.inputAnimationView = InputAnimationView:new()
	self.discordGameplayView = DiscordGameplayView:new()
	self.judgementView = JudgementView:new()
end

GameplayView.load = function(self)
	local playfieldView = self.playfieldView
	local rhythmView = self.rhythmView
	local valueView = self.valueView
	local progressView = self.progressView
	local menuProgressView = self.menuProgressView
	local pointGraphView = self.pointGraphView
	local discordGameplayView = self.discordGameplayView
	local sequenceView = self.sequenceView
	local configModel = self.configModel
	local cameraView = self.cameraView

	local config = configModel.configs.settings

	self.navigator.rhythmModel = self.rhythmModel

	cameraView.perspective = config.graphics.perspective

	rhythmView.navigator = self.navigator
	rhythmView.configModel = self.configModel
	rhythmView.noteSkin = self.noteSkin
	rhythmView.rhythmModel = self.rhythmModel
	rhythmView:setBgaEnabled("video", config.gameplay.bga.video)
	rhythmView:setBgaEnabled("image", config.gameplay.bga.image)

	valueView.scoreSystem = self.scoreSystem
	valueView.noteChartDataEntry = self.noteChartModel.noteChartDataEntry

	progressView.scoreSystem = self.scoreSystem
	progressView.rhythmModel = self.rhythmModel
	progressView.noteChartModel = self.noteChartModel

	menuProgressView.rhythmModel = self.rhythmModel

	pointGraphView.scoreSystem = self.scoreSystem
	pointGraphView.noteChartModel = self.noteChartModel

	self.imageView.root = self.noteSkin.directoryPath
	self.imageAnimationView.root = self.noteSkin.directoryPath

	self.backgroundView.settings = config
	self.gaussianBlurView.settings = config
	self.judgementView.scoreSystem = self.scoreSystem

	playfieldView:setSequenceConfig(self.noteSkin.playField)
	playfieldView:setView("RhythmView", rhythmView)
	playfieldView:setView("ValueView", valueView)
	playfieldView:setView("ProgressView", progressView)
	playfieldView:setView("PointGraphView", pointGraphView)
	playfieldView:setView("InputView", self.inputView)
	playfieldView:setView("InputAnimationView", self.inputAnimationView)
	playfieldView:setView("CameraView", self.cameraView)
	playfieldView:setView("ImageView", self.imageView)
	playfieldView:setView("ImageAnimationView", self.imageAnimationView)
	playfieldView:setView("JudgementView", self.judgementView)
	playfieldView:load()

	sequenceView:setView("PlayfieldView", playfieldView)
	sequenceView:setView("ProgressView", menuProgressView)

	discordGameplayView.rhythmModel = self.rhythmModel
	discordGameplayView.noteChartModel = self.noteChartModel

	ScreenView.load(self)
end

return GameplayView
