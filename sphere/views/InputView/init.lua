local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local InputViewConfig = require(viewspackage .. "InputView.InputViewConfig")
local InputNavigator = require(viewspackage .. "InputView.InputNavigator")
local InputListView = require(viewspackage .. "InputView.InputListView")

local InputView = ScreenView:new({construct = false})

InputView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = InputViewConfig
	self.navigator = InputNavigator:new()
	self.noteSkinListView = InputListView:new()
end

InputView.load = function(self)
	local navigator = self.navigator
	local noteSkinListView = self.noteSkinListView
	local config = self.configModel:getConfig("input")

	navigator.noteChartModel = self.noteChartModel
	navigator.inputModel = self.inputModel

	noteSkinListView.navigator = navigator
	noteSkinListView.noteChartModel = self.noteChartModel
	noteSkinListView.inputModel = self.inputModel
	noteSkinListView.configInput = config

	self.backgroundView.settings = self.configModel:getConfig("settings")

	local sequenceView = self.sequenceView
	sequenceView:setView("InputListView", noteSkinListView)

	ScreenView.load(self)
end

return InputView
