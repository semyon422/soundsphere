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

local SelectView = ScreenView:new()

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
	local navigator = self.navigator

	local configSelect = self.configModel:getConfig("select")
	local configModifier = self.configModel:getConfig("modifier")
	self.configSelect = configSelect
	self.configModifier = configModifier

	navigator.selectModel = self.selectModel

	noteChartSetListView.navigator = self.navigator
	noteChartSetListView.noteChartSetLibraryModel = self.noteChartSetLibraryModel
	noteChartSetListView.selectModel = self.selectModel

	noteChartListView.navigator = self.navigator
	noteChartListView.noteChartLibraryModel = self.noteChartLibraryModel
	noteChartListView.selectModel = self.selectModel

	searchFieldView.searchModel = self.searchModel

	modifierIconGridView.modifierModel = self.modifierModel
	modifierIconGridView.configModifier = configModifier

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
