local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local ResultNavigator = require(viewspackage .. "ResultView.ResultNavigator")
local ResultViewConfig = require(viewspackage .. "ResultView.ResultViewConfig")

local PointGraphView = require("sphere.views.GameplayView.PointGraphView")
local ScoreListView	= require("sphere.views.ResultView.ScoreListView")
local ModifierIconGridView = require(viewspackage .. "SelectView.ModifierIconGridView")
local StageInfoView = require(viewspackage .. "SelectView.StageInfoView")

local ResultView = ScreenView:new({construct = false})

ResultView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = ResultViewConfig
	self.navigator = ResultNavigator:new()
	self.pointGraphView = PointGraphView:new()
	self.scoreListView = ScoreListView:new()
	self.modifierIconGridView = ModifierIconGridView:new()
	self.stageInfoView = StageInfoView:new()
end

ResultView.load = function(self)
	local valueView = self.valueView
	local pointGraphView = self.pointGraphView
	local modifierIconGridView = self.modifierIconGridView
	local stageInfoView = self.stageInfoView
	local scoreListView = self.scoreListView
	local inspectView = self.inspectView
	local userInfoView = self.userInfoView
	local navigator = self.navigator

	local scoreSystem = self.rhythmModel.scoreEngine.scoreSystem:getSlice()

	inspectView.scoreSystem = scoreSystem

	valueView.scoreSystem = scoreSystem
	valueView.noteChartDataEntry = self.noteChartModel.noteChartDataEntry

	pointGraphView.scoreEngine = self.rhythmModel.scoreEngine
	pointGraphView.noteChartModel = self.noteChartModel
	pointGraphView.selectModel = self.selectModel

	modifierIconGridView.modifierModel = self.modifierModel
	modifierIconGridView.selectModel = self.selectModel
	modifierIconGridView.scoreEngine = self.rhythmModel.scoreEngine

	scoreListView.scoreLibraryModel = self.scoreLibraryModel
	scoreListView.selectModel = self.selectModel
	scoreListView.rhythmModel = self.rhythmModel
	scoreListView.navigator = navigator

	stageInfoView.selectModel = self.selectModel
	stageInfoView.scoreEngine = self.rhythmModel.scoreEngine

	userInfoView.navigator = navigator
	userInfoView.onlineConfig = self.configModel:getConfig("online")

	navigator.selectModel = self.selectModel
	navigator.scoreLibraryModel = self.scoreLibraryModel

	local sequenceView = self.sequenceView
	sequenceView:setView("PointGraphView", pointGraphView)
	sequenceView:setView("ModifierIconGridView", modifierIconGridView)
	sequenceView:setView("StageInfoView", stageInfoView)
	sequenceView:setView("ScoreListView", scoreListView)

	ScreenView.load(self)
end

return ResultView
