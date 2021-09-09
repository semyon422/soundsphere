local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local SelectViewConfig = require(viewspackage .. "SelectView.SelectViewConfig")
local SelectNavigator = require(viewspackage .. "SelectView.SelectNavigator")
local NoteChartSetListView = require(viewspackage .. "SelectView.NoteChartSetListView")
local NoteChartListView = require(viewspackage .. "SelectView.NoteChartListView")
local SearchFieldView = require(viewspackage .. "SelectView.SearchFieldView")
local SortStepperView = require(viewspackage .. "SelectView.SortStepperView")
local StageInfoView = require(viewspackage .. "SelectView.StageInfoView")
local ModifierIconGridView = require(viewspackage .. "SelectView.ModifierIconGridView")

local SelectView = ScreenView:new({construct = false})

SelectView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = SelectViewConfig
	self.navigator = SelectNavigator:new()
	self.noteChartListView = NoteChartListView:new()
	self.noteChartSetListView = NoteChartSetListView:new()
	self.searchFieldView = SearchFieldView:new()
	self.sortStepperView = SortStepperView:new()
	self.stageInfoView = StageInfoView:new()
	self.modifierIconGridView = ModifierIconGridView:new()
end

SelectView.load = function(self)
	local noteChartSetListView = self.noteChartSetListView
	local noteChartListView = self.noteChartListView
	local searchFieldView = self.searchFieldView
	local modifierIconGridView = self.modifierIconGridView
	local stageInfoView = self.stageInfoView
	local sortStepperView = self.sortStepperView
	local valueView = self.valueView
	local userInfoView = self.userInfoView
	local navigator = self.navigator

	navigator.selectModel = self.selectModel

	valueView.updateModel = self.updateModel

	noteChartSetListView.navigator = self.navigator
	noteChartSetListView.noteChartSetLibraryModel = self.noteChartSetLibraryModel
	noteChartSetListView.selectModel = self.selectModel

	noteChartListView.navigator = self.navigator
	noteChartListView.noteChartLibraryModel = self.noteChartLibraryModel
	noteChartListView.selectModel = self.selectModel

	searchFieldView.noteChartSetLibraryModel = self.noteChartSetLibraryModel
	searchFieldView.searchModel = self.searchModel

	modifierIconGridView.selectModel = self.selectModel
	modifierIconGridView.modifierModel = self.modifierModel
	modifierIconGridView.scoreLibraryModel = self.scoreLibraryModel

	stageInfoView.selectModel = self.selectModel
	stageInfoView.scoreLibraryModel = self.scoreLibraryModel

	userInfoView.onlineConfig = self.configModel:getConfig("online")

	sortStepperView.sortModel = self.sortModel
	sortStepperView.navigator = navigator

	local sequenceView = self.sequenceView
	sequenceView:setView("NoteChartSetListView", noteChartSetListView)
	sequenceView:setView("NoteChartListView", noteChartListView)
	sequenceView:setView("SearchFieldView", searchFieldView)
	sequenceView:setView("SortStepperView", self.sortStepperView)
	sequenceView:setView("StageInfoView", self.stageInfoView)
	sequenceView:setView("ModifierIconGridView", modifierIconGridView)

	ScreenView.load(self)
end

return SelectView
