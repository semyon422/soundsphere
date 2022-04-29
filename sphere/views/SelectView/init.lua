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
local CollectionListView = require(viewspackage .. "SelectView.CollectionListView")
local OsudirectListView = require(viewspackage .. "SelectView.OsudirectListView")
local OsudirectDifficultiesListView = require(viewspackage .. "SelectView.OsudirectDifficultiesListView")
local CacheView = require(viewspackage .. "SelectView.CacheView")
local NoteSkinView = require("sphere.views.NoteSkinView")
local InputView = require("sphere.views.InputView")

local SelectView = ScreenView:new({construct = false})

SelectView.views = {
	{"noteChartListView", NoteChartListView, "NoteChartListView"},
	{"noteChartSetListView", NoteChartSetListView, "NoteChartSetListView"},
	{"searchFieldView", SearchFieldView, "SearchFieldView"},
	{"sortStepperView", SortStepperView, "SortStepperView"},
	{"stageInfoView", StageInfoView, "StageInfoView"},
	{"modifierIconGridView", ModifierIconGridView, "ModifierIconGridView"},
	{"collectionListView", CollectionListView, "CollectionListView"},
	{"osudirectListView", OsudirectListView, "OsudirectListView"},
	{"osudirectDifficultiesListView", OsudirectDifficultiesListView, "OsudirectDifficultiesListView"},
	{"cacheView", CacheView, "CacheView"},
}

SelectView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = SelectViewConfig
	self.navigator = SelectNavigator:new()
	self:createViews(ScreenView.views)
	self:createViews(self.views)

	self.noteSkinView = NoteSkinView:new()
	self.inputView = InputView:new()
end

SelectView.load = function(self)
	self:loadViews(ScreenView.views)
	self:loadViews(self.views)
	ScreenView.load(self)

	self.noteSkinView.gameController = self.gameController
	self.noteSkinView.navigator = self.navigator
	self.noteSkinView.isOpen = self.navigator.isNoteSkinsOpen

	self.inputView.gameController = self.gameController
	self.inputView.navigator = self.navigator
	self.inputView.isOpen = self.navigator.isInputOpen
end

SelectView.draw = function(self)
	ScreenView.draw(self)
	self.noteSkinView:draw()
	self.inputView:draw()
end

return SelectView
