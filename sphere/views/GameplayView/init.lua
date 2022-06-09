local viewspackage = (...):match("^(.-%.views%.)")

local RhythmView = require("sphere.views.RhythmView")
local GameplayViewConfig = require("sphere.views.GameplayView.GameplayViewConfig")
local ProgressView	= require("sphere.views.GameplayView.ProgressView")
local ImageProgressView	= require("sphere.views.GameplayView.ImageProgressView")
local PointGraphView = require("sphere.views.GameplayView.PointGraphView")
local HitErrorView = require("sphere.views.GameplayView.HitErrorView")
local InputView	= require("sphere.views.GameplayView.InputView")
local InputAnimationView	= require("sphere.views.GameplayView.InputAnimationView")
local GameplayNavigator	= require("sphere.views.GameplayView.GameplayNavigator")
local JudgementView	= require("sphere.views.GameplayView.JudgementView")
local DeltaTimeJudgementView	= require("sphere.views.GameplayView.DeltaTimeJudgementView")
local MatchPlayersView	= require("sphere.views.GameplayView.MatchPlayersView")
local ScreenView = require(viewspackage .. "ScreenView")

local GameplayView = ScreenView:new({construct = false})

GameplayView.views = {
	{"menuProgressView", ProgressView, "ProgressView"},
	{"rhythmView", RhythmView, "RhythmView"},
	{"progressView", ProgressView, "ProgressView"},
	{"imageProgressView", ImageProgressView, "ImageProgressView"},
	{"pointGraphView", PointGraphView, "PointGraphView"},
	{"hitErrorView", HitErrorView, "HitErrorView"},
	{"inputView", InputView, "InputView"},
	{"inputAnimationView", InputAnimationView, "InputAnimationView"},
	{"judgementView", JudgementView, "JudgementView"},
	{"deltaTimeJudgementView", DeltaTimeJudgementView, "DeltaTimeJudgementView"},
	{"matchPlayersView", MatchPlayersView, "MatchPlayersView"},
}

GameplayView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = GameplayViewConfig
	self.navigator = GameplayNavigator:new()
	self:createViews(ScreenView.views)
	self:createViews(self.views)
end

GameplayView.load = function(self)
	self.game.rhythmModel.observable:add(self.sequenceView)
	self.game.gameplayController:load()

	local noteSkin = self.game.rhythmModel.graphicEngine.noteSkin
	self.imageAnimationView.root = noteSkin.directoryPath
	self.imageView.root = noteSkin.directoryPath
	self.imageValueView.root = noteSkin.directoryPath
	self.imageProgressView.root = noteSkin.directoryPath
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
	self.game.gameplayController:unload()
	self.game.rhythmModel.observable:remove(self.sequenceView)
	ScreenView.unload(self)
	self.viewConfig[self.playfieldViewConfigIndex] = self.playfieldViewConfig
end

GameplayView.update = function(self, dt)
	self.game.gameplayController:update(dt)
	ScreenView.update(self, dt)
end

GameplayView.receive = function(self, event)
	self.game.gameplayController:receive(event)
	ScreenView.receive(self, event)
end

return GameplayView
