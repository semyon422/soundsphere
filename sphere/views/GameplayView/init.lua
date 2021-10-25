local viewspackage = (...):match("^(.-%.views%.)")

local RhythmView = require("sphere.views.RhythmView")
local GameplayViewConfig = require("sphere.views.GameplayView.GameplayViewConfig")
local ProgressView	= require("sphere.views.GameplayView.ProgressView")
local PointGraphView = require("sphere.views.GameplayView.PointGraphView")
local HitErrorView = require("sphere.views.GameplayView.HitErrorView")
local InputView	= require("sphere.views.GameplayView.InputView")
local InputAnimationView	= require("sphere.views.GameplayView.InputAnimationView")
local GameplayNavigator	= require("sphere.views.GameplayView.GameplayNavigator")
local JudgementView	= require("sphere.views.GameplayView.JudgementView")
local DeltaTimeJudgementView	= require("sphere.views.GameplayView.DeltaTimeJudgementView")
local ScreenView = require(viewspackage .. "ScreenView")

local GameplayView = ScreenView:new({construct = false})

GameplayView.views = {
	{"menuProgressView", ProgressView, "ProgressView"},
	{"rhythmView", RhythmView, "RhythmView"},
	{"progressView", ProgressView, "ProgressView"},
	{"pointGraphView", PointGraphView, "PointGraphView"},
	{"hitErrorView", HitErrorView, "HitErrorView"},
	{"inputView", InputView, "InputView"},
	{"inputAnimationView", InputAnimationView, "InputAnimationView"},
	{"judgementView", JudgementView, "JudgementView"},
	{"deltaTimeJudgementView", DeltaTimeJudgementView, "DeltaTimeJudgementView"},
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
	for i, config in ipairs(self.viewConfig) do
		if config.class == "PlayfieldView" then
			self.playfieldViewConfig = self.viewConfig[i]
			self.playfieldViewConfigIndex = i
			self.viewConfig[i] = noteSkin.playField
		end
	end
	ScreenView.load(self)
end

GameplayView.unload = function(self)
	self.viewConfig[self.playfieldViewConfigIndex] = self.playfieldViewConfig
	ScreenView.unload(self)
end

return GameplayView
