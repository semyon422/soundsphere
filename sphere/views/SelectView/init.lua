local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")

local SequenceView = require(viewspackage .. "SequenceView")
local ScrollBarView = require(viewspackage .. "ScrollBarView")
local RectangleView = require(viewspackage .. "RectangleView")
local LineView = require(viewspackage .. "LineView")
local UserInfoView = require(viewspackage .. "UserInfoView")
local LogoView = require(viewspackage .. "LogoView")
local ScreenMenuView = require(viewspackage .. "ScreenMenuView")
local SelectViewConfig = require(viewspackage .. "SelectView.SelectViewConfig")
local SelectNavigator = require(viewspackage .. "SelectView.SelectNavigator")
local NoteChartSetListView = require(viewspackage .. "SelectView.NoteChartSetListView")
local NoteChartListView = require(viewspackage .. "SelectView.NoteChartListView")
local SearchFieldView = require(viewspackage .. "SelectView.SearchFieldView")
local SortStepperView = require(viewspackage .. "SelectView.SortStepperView")
local StageInfoView = require(viewspackage .. "SelectView.StageInfoView")
local ModifierIconGridView = require(viewspackage .. "SelectView.ModifierIconGridView")
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
	self.userInfoView = UserInfoView:new()
	self.logoView = LogoView:new()
	self.scrollBarView = ScrollBarView:new()
	self.stageInfoView = StageInfoView:new()
	self.modifierIconGridView = ModifierIconGridView:new()
	self.backgroundView = BackgroundView:new()
	self.rectangleView = RectangleView:new()
	self.lineView = LineView:new()
end

SelectView.load = function(self)
	local noteChartSetListView = self.noteChartSetListView
	local noteChartListView = self.noteChartListView
	local searchFieldView = self.searchFieldView
	local screenMenuView = self.screenMenuView
	local modifierIconGridView = self.modifierIconGridView
	local navigator = self.navigator
	local sequenceView = self.sequenceView
	local backgroundView = self.backgroundView

	local configSelect = self.configModel:getConfig("select")
	local configModifier = self.configModel:getConfig("modifier")
	self.configSelect = configSelect
	self.configModifier = configModifier

	navigator.selectModel = self.selectModel
	navigator.view = self

	noteChartSetListView.navigator = self.navigator
	noteChartSetListView.noteChartSetLibraryModel = self.noteChartSetLibraryModel
	noteChartSetListView.selectModel = self.selectModel

	noteChartListView.navigator = self.navigator
	noteChartListView.noteChartLibraryModel = self.noteChartLibraryModel
	noteChartListView.selectModel = self.selectModel

	searchFieldView.searchLineModel = self.searchLineModel

	modifierIconGridView.modifierModel = self.modifierModel
	modifierIconGridView.configModifier = configModifier

	screenMenuView.navigator = self.navigator

	backgroundView.backgroundModel = self.backgroundModel

	sequenceView:setSequenceConfig(self.selectViewConfig)
	sequenceView:setView("NoteChartSetListView", noteChartSetListView)
	sequenceView:setView("NoteChartListView", noteChartListView)
	sequenceView:setView("BackgroundView", backgroundView)
	sequenceView:setView("SearchFieldView", searchFieldView)
	sequenceView:setView("SortStepperView", self.sortStepperView)
	sequenceView:setView("ScreenMenuView", screenMenuView)
	sequenceView:setView("UserInfoView", self.userInfoView)
	sequenceView:setView("LogoView", self.logoView)
	sequenceView:setView("ScrollBarView", self.scrollBarView)
	sequenceView:setView("StageInfoView", self.stageInfoView)
	sequenceView:setView("ModifierIconGridView", modifierIconGridView)
	sequenceView:setView("RectangleView", self.rectangleView)
	sequenceView:setView("LineView", self.lineView)
	sequenceView:load()

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
