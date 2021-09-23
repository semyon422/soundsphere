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

GameplayView.views = {
	{"playfieldView", SequenceView, "PlayfieldView"},
	{"menuProgressView", ProgressView, "ProgressView"},
	{"rhythmView", RhythmView, "RhythmView"},
	{"progressView", ProgressView, "ProgressView"},
	{"pointGraphView", PointGraphView, "PointGraphView"},
	{"inputView", InputView, "InputView"},
	{"inputAnimationView", InputAnimationView, "InputAnimationView"},
	{"judgementView", JudgementView, "JudgementView"},
}

GameplayView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = GameplayViewConfig
	self.navigator = GameplayNavigator:new()
	self:createViews(ScreenView.views)
	self:createViews(self.views)
end

GameplayView.load = function(self)
	local noteSkin = self.gameController.rhythmModel.graphicEngine.noteSkin
	self.imageAnimationView.root = noteSkin.directoryPath
	self.imageView.root = noteSkin.directoryPath
	self:loadViews(ScreenView.views)
	self:loadViews(self.views)
	self.playfieldView:setSequenceConfig(noteSkin.playField)
	self.playfieldView:load()
	ScreenView.load(self)
end

return GameplayView
