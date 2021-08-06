local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local ResultNavigator = require(viewspackage .. "ResultView.ResultNavigator")
local ResultViewConfig = require(viewspackage .. "ResultView.ResultViewConfig")

local ValueView	= require("sphere.views.GameplayView.ValueView")
local PointGraphView = require("sphere.views.GameplayView.PointGraphView")
local ImageView	= require("sphere.views.GameplayView.ImageView")

local ResultView = ScreenView:new()

ResultView.construct = function(self)
	self.viewConfig = ResultViewConfig
	self.navigator = ResultNavigator:new()
	self.valueView = ValueView:new()
	self.pointGraphView = PointGraphView:new()
	self.imageView = ImageView:new()
end

ResultView.load = function(self)
	local valueView = self.valueView
	local pointGraphView = self.pointGraphView
	local imageView = self.imageView
	local sequenceView = self.sequenceView

	local scoreSystem = self.rhythmModel.scoreEngine.scoreSystem

	valueView.scoreSystem = scoreSystem
	valueView.noteChartDataEntry = self.noteChartModel.noteChartDataEntry
	valueView.modifierString = self.modifierModel:getString()

	pointGraphView.scoreSystem = scoreSystem
	pointGraphView.noteChartModel = self.noteChartModel

	imageView.root = "."

	sequenceView:setView("ValueView", valueView)
	sequenceView:setView("PointGraphView", pointGraphView)
	sequenceView:setView("ImageView", imageView)

	ScreenView.load(self)
end

return ResultView
