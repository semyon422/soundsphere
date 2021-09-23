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

SelectView.views = {
	{"noteChartListView", NoteChartListView, "NoteChartListView"},
	{"noteChartSetListView", NoteChartSetListView, "NoteChartSetListView"},
	{"searchFieldView", SearchFieldView, "SearchFieldView"},
	{"sortStepperView", SortStepperView, "SortStepperView"},
	{"stageInfoView", StageInfoView, "StageInfoView"},
	{"modifierIconGridView", ModifierIconGridView, "ModifierIconGridView"},
}

SelectView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = SelectViewConfig
	self.navigator = SelectNavigator:new()
	self:createViews(ScreenView.views)
	self:createViews(self.views)
end

SelectView.load = function(self)
	self:loadViews(ScreenView.views)
	self:loadViews(self.views)
	ScreenView.load(self)
end

return SelectView
