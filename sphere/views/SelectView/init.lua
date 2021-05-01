local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")

local SequenceView = require(viewspackage .. "SequenceView")
local SelectViewConfig = require(viewspackage .. "SelectView.SelectViewConfig")
local SelectNavigator = require(viewspackage .. "SelectView.SelectNavigator")
local NoteChartSetListView = require(viewspackage .. "SelectView.NoteChartSetListView")
local NoteChartListView = require(viewspackage .. "SelectView.NoteChartListView")
local ScoreListView = require(viewspackage .. "SelectView.ScoreListView")
local SearchFieldView = require(viewspackage .. "SelectView.SearchFieldView")
local SortStepperView = require(viewspackage .. "SelectView.SortStepperView")
local ScreenMenuView = require(viewspackage .. "SelectView.ScreenMenuView")
local BackgroundView = require(viewspackage .. "BackgroundView")

local SelectView = Class:new()

SelectView.construct = function(self)
	self.selectViewConfig = SelectViewConfig
	self.navigator = SelectNavigator:new()
	self.sequenceView = SequenceView:new()
	self.noteChartListView = NoteChartListView:new()
	self.noteChartSetListView = NoteChartSetListView:new()
	self.searchFieldView = SearchFieldView:new()
	self.sortStepperView = SortStepperView:new()
	self.screenMenuView = ScreenMenuView:new()
end

SelectView.load = function(self)
	local noteChartSetListView = self.noteChartSetListView
	local noteChartListView = self.noteChartListView
	local searchFieldView = self.searchFieldView
	local sortStepperView = self.sortStepperView
	local screenMenuView = self.screenMenuView

	local selectConfig = self.configModel:getConfig("select")
	self.selectConfig = selectConfig

	local navigator = self.navigator
	navigator.selectModel = self.selectModel
	navigator.view = self

	noteChartSetListView.navigator = self.navigator
	noteChartSetListView.noteChartSetLibraryModel = self.noteChartSetLibraryModel
	noteChartSetListView.selectModel = self.selectModel

	noteChartListView.navigator = self.navigator
	noteChartListView.noteChartLibraryModel = self.noteChartLibraryModel
	noteChartListView.selectModel = self.selectModel

	-- local scoreListView = ScoreListView:new()
	-- scoreListView.navigator = navigator
	-- scoreListView.config = config
	-- scoreListView.view = self

	searchFieldView.searchLineModel = self.searchLineModel

	screenMenuView.navigator = self.navigator

	local backgroundView = BackgroundView:new()
	self.backgroundView = backgroundView
	backgroundView.view = self

	local sequenceView = self.sequenceView
	sequenceView:setSequenceConfig(self.selectViewConfig)
	sequenceView:setView("NoteChartSetListView", noteChartSetListView)
	sequenceView:setView("NoteChartListView", noteChartListView)
	sequenceView:setView("BackgroundView", backgroundView)
	sequenceView:setView("SearchFieldView", searchFieldView)
	sequenceView:setView("SortStepperView", sortStepperView)
	sequenceView:setView("ScreenMenuView", screenMenuView)

	self.sequenceView:load()

	navigator:load()
end

SelectView.unload = function(self)
	self.navigator:unload()
	self.sequenceView:unload()
end

SelectView.receive = function(self, event)
	self.navigator:receive(event)
	self.sequenceView:receive(event)
end

SelectView.update = function(self, dt)
	self.navigator:update()
	self.sequenceView:update(dt)
end

SelectView.draw = function(self)
	self.sequenceView:draw()
end

return SelectView
