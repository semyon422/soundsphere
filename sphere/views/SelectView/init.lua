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
local UserInfoView = require(viewspackage .. "SelectView.UserInfoView")
local LogoView = require(viewspackage .. "SelectView.LogoView")
local NoteChartSetScrollBarView = require(viewspackage .. "SelectView.NoteChartSetScrollBarView")
local StageInfoScrollBarView = require(viewspackage .. "SelectView.StageInfoScrollBarView")
local StageInfoView = require(viewspackage .. "SelectView.StageInfoView")
local ModifierIconGridView = require(viewspackage .. "SelectView.ModifierIconGridView")
local SelectFrameView = require(viewspackage .. "SelectView.SelectFrameView")
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
	self.noteChartSetScrollBarView = NoteChartSetScrollBarView:new()
	self.stageInfoScrollBarView = StageInfoScrollBarView:new()
	self.stageInfoView = StageInfoView:new()
	self.modifierIconGridView = ModifierIconGridView:new()
	self.selectFrameView = SelectFrameView:new()
	self.backgroundView = BackgroundView:new()
end

SelectView.load = function(self)
	local noteChartSetListView = self.noteChartSetListView
	local noteChartListView = self.noteChartListView
	local searchFieldView = self.searchFieldView
	local sortStepperView = self.sortStepperView
	local screenMenuView = self.screenMenuView
	local userInfoView = self.userInfoView
	local logoView = self.logoView
	local noteChartSetScrollBarView = self.noteChartSetScrollBarView
	local stageInfoScrollBarView = self.stageInfoScrollBarView
	local stageInfoView = self.stageInfoView
	local modifierIconGridView = self.modifierIconGridView
	local selectFrameView = self.selectFrameView
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

	-- local scoreListView = ScoreListView:new()
	-- scoreListView.navigator = navigator
	-- scoreListView.config = config
	-- scoreListView.view = self

	searchFieldView.searchLineModel = self.searchLineModel

	modifierIconGridView.modifierModel = self.modifierModel
	modifierIconGridView.configModifier = configModifier

	noteChartSetScrollBarView.selectModel = self.selectModel
	noteChartSetScrollBarView.noteChartSetLibraryModel = self.noteChartSetLibraryModel

	screenMenuView.navigator = self.navigator

	backgroundView.backgroundModel = self.backgroundModel

	sequenceView:setSequenceConfig(self.selectViewConfig)
	sequenceView:setView("NoteChartSetListView", noteChartSetListView)
	sequenceView:setView("NoteChartListView", noteChartListView)
	sequenceView:setView("BackgroundView", backgroundView)
	sequenceView:setView("SearchFieldView", searchFieldView)
	sequenceView:setView("SortStepperView", sortStepperView)
	sequenceView:setView("ScreenMenuView", screenMenuView)
	sequenceView:setView("UserInfoView", userInfoView)
	sequenceView:setView("LogoView", logoView)
	sequenceView:setView("NoteChartSetScrollBarView", noteChartSetScrollBarView)
	sequenceView:setView("StageInfoScrollBarView", stageInfoScrollBarView)
	sequenceView:setView("StageInfoView", stageInfoView)
	sequenceView:setView("ModifierIconGridView", modifierIconGridView)
	sequenceView:setView("SelectFrameView", selectFrameView)
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
