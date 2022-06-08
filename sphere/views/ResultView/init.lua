local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local ResultNavigator = require(viewspackage .. "ResultView.ResultNavigator")
local ResultViewConfig = require(viewspackage .. "ResultView.ResultViewConfig")

local PointGraphView = require("sphere.views.GameplayView.PointGraphView")
local ScoreListView	= require("sphere.views.ResultView.ScoreListView")
local ModifierIconGridView = require(viewspackage .. "SelectView.ModifierIconGridView")
local StageInfoView = require(viewspackage .. "SelectView.StageInfoView")
local MatchPlayersView	= require("sphere.views.GameplayView.MatchPlayersView")

local ResultView = ScreenView:new({construct = false})

ResultView.views = {
	{"pointGraphView", PointGraphView, "PointGraphView"},
	{"modifierIconGridView", ModifierIconGridView, "ModifierIconGridView"},
	{"stageInfoView", StageInfoView, "StageInfoView"},
	{"scoreListView", ScoreListView, "ScoreListView"},
	{"MatchPlayersView", MatchPlayersView, "MatchPlayersView"},
}

ResultView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = ResultViewConfig
	self.navigator = ResultNavigator:new()
	self:createViews(ScreenView.views)
	self:createViews(self.views)
end

ResultView.load = function(self)
	self.controller = self.game.resultController
	self:loadViews(ScreenView.views)
	self:loadViews(self.views)
	ScreenView.load(self)
end

return ResultView
