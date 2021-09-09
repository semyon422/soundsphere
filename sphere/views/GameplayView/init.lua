local viewspackage = (...):match("^(.-%.views%.)")

local RhythmView = require("sphere.views.RhythmView")
local GameplayViewConfig = require("sphere.views.GameplayView.GameplayViewConfig")
local DiscordGameplayView = require("sphere.views.DiscordGameplayView")
local ProgressView	= require("sphere.views.GameplayView.ProgressView")
local PointGraphView = require("sphere.views.GameplayView.PointGraphView")
local InputImageView	= require("sphere.views.GameplayView.InputImageView")
local GameplayNavigator	= require("sphere.views.GameplayView.GameplayNavigator")
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
	self.inputImageView = InputImageView:new()
	self.discordGameplayView = DiscordGameplayView:new()
end

GameplayView.load = function(self)
	local playfieldView = self.playfieldView
	local rhythmView = self.rhythmView
	local valueView = self.valueView
	local progressView = self.progressView
	local menuProgressView = self.menuProgressView
	local pointGraphView = self.pointGraphView
	local imageView = self.imageView
	local inputImageView = self.inputImageView
	local discordGameplayView = self.discordGameplayView
	local sequenceView = self.sequenceView
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

	menuProgressView.rhythmModel = self.rhythmModel

	pointGraphView.scoreSystem = self.scoreSystem
	pointGraphView.noteChartModel = self.noteChartModel

	imageView.root = self.noteSkin.directoryPath
	inputImageView.root = self.noteSkin.directoryPath

	playfieldView:setSequenceConfig(self.noteSkin.playField)
	playfieldView:setView("RhythmView", rhythmView)
	playfieldView:setView("ValueView", valueView)
	playfieldView:setView("ProgressView", progressView)
	playfieldView:setView("PointGraphView", pointGraphView)
	playfieldView:setView("InputImageView", inputImageView)
	playfieldView:load()

	sequenceView:setView("PlayfieldView", playfieldView)
	sequenceView:setView("ProgressView", menuProgressView)

	discordGameplayView.rhythmModel = self.rhythmModel
	discordGameplayView.noteChartModel = self.noteChartModel

	ScreenView.load(self)
end

return GameplayView
