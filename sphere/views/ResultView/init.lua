local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local ResultNavigator = require(viewspackage .. "ResultView.ResultNavigator")
local ResultViewConfig = require(viewspackage .. "ResultView.ResultViewConfig")

local ValueView	= require("sphere.views.GameplayView.ValueView")
local PointGraphView = require("sphere.views.GameplayView.PointGraphView")
local ImageView	= require("sphere.views.GameplayView.ImageView")
local ScoreListView	= require("sphere.views.ResultView.ScoreListView")
local ModifierIconGridView = require(viewspackage .. "SelectView.ModifierIconGridView")
local StageInfoView = require(viewspackage .. "SelectView.StageInfoView")

local ResultView = ScreenView:new()

ResultView.construct = function(self)
	self.viewConfig = ResultViewConfig
	self.navigator = ResultNavigator:new()
	self.valueView = ValueView:new()
	self.pointGraphView = PointGraphView:new()
	self.imageView = ImageView:new()
	self.scoreListView = ScoreListView:new()
	self.modifierIconGridView = ModifierIconGridView:new()
	self.stageInfoView = StageInfoView:new()
end

ResultView.load = function(self)
	local valueView = self.valueView
	local pointGraphView = self.pointGraphView
	local imageView = self.imageView
	local modifierIconGridView = self.modifierIconGridView
	local stageInfoView = self.stageInfoView
	local scoreListView = self.scoreListView
	local inspectView = self.inspectView
	local navigator = self.navigator

	local configModifier = self.configModel:getConfig("modifier")

	local scoreSystem = self.rhythmModel.scoreEngine.scoreSystem:getSlice()

	inspectView.scoreSystem = scoreSystem

	valueView.scoreSystem = scoreSystem
	valueView.noteChartDataEntry = self.noteChartModel.noteChartDataEntry
	valueView.modifierString = self.modifierModel:getString()

	pointGraphView.scoreEngine = self.rhythmModel.scoreEngine
	pointGraphView.noteChartModel = self.noteChartModel
	pointGraphView.selectModel = self.selectModel

	modifierIconGridView.modifierModel = self.modifierModel
	modifierIconGridView.configModifier = configModifier

	scoreListView.scoreLibraryModel = self.scoreLibraryModel
	scoreListView.selectModel = self.selectModel
	scoreListView.rhythmModel = self.rhythmModel
	scoreListView.navigator = navigator

	stageInfoView.selectModel = self.selectModel
	stageInfoView.scoreEngine = self.rhythmModel.scoreEngine

	navigator.selectModel = self.selectModel
	navigator.scoreLibraryModel = self.scoreLibraryModel

	imageView.root = "."

	local sequenceView = self.sequenceView
	sequenceView:setView("ValueView", valueView)
	sequenceView:setView("PointGraphView", pointGraphView)
	sequenceView:setView("ImageView", imageView)
	sequenceView:setView("ModifierIconGridView", modifierIconGridView)
	sequenceView:setView("StageInfoView", stageInfoView)
	sequenceView:setView("ScoreListView", scoreListView)

	ScreenView.load(self)
end

return ResultView
