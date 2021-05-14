local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local NoteSkinViewConfig = require(viewspackage .. "NoteSkinView.NoteSkinViewConfig")
local NoteSkinNavigator = require(viewspackage .. "NoteSkinView.NoteSkinNavigator")
local NoteSkinListView = require(viewspackage .. "NoteSkinView.NoteSkinListView")

local NoteSkinView = ScreenView:new()

NoteSkinView.construct = function(self)
	self.viewConfig = NoteSkinViewConfig
	self.navigator = NoteSkinNavigator:new()
	self.noteSkinListView = NoteSkinListView:new()
end

NoteSkinView.load = function(self)
	local navigator = self.navigator
	local noteSkinListView = self.noteSkinListView

	navigator.noteChartModel = self.noteChartModel
	navigator.noteSkinModel = self.noteSkinModel

	noteSkinListView.navigator = navigator
	noteSkinListView.noteChartModel = self.noteChartModel
	noteSkinListView.noteSkinModel = self.noteSkinModel
	noteSkinListView.view = self

	local sequenceView = self.sequenceView
	sequenceView:setView("NoteSkinListView", noteSkinListView)

	ScreenView.load(self)
end

return NoteSkinView
