local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")

local SequenceView = require(viewspackage .. "SequenceView")
local SelectViewConfig = require(viewspackage .. "SelectView.SelectViewConfig")
local SelectNavigator = require(viewspackage .. "SelectView.SelectNavigator")
local NoteChartSetListView = require(viewspackage .. "SelectView.NoteChartSetListView")
local NoteChartListView = require(viewspackage .. "SelectView.NoteChartListView")
local ScoreListView = require(viewspackage .. "SelectView.ScoreListView")
local SearchLineView = require(viewspackage .. "SelectView.SearchLineView")
local SelectMenuView = require(viewspackage .. "SelectView.SelectMenuView")
local BackgroundView = require(viewspackage .. "BackgroundView")

local SelectView = Class:new()

SelectView.construct = function(self)
	self.selectViewConfig = SelectViewConfig
	self.sequenceView = SequenceView:new()
	self.noteChartListView = NoteChartListView:new()
	self.noteChartSetListView = NoteChartSetListView:new()
	self.searchLineView = SearchLineView:new()
end

SelectView.load = function(self)
	local noteChartSetListView = self.noteChartSetListView
	local noteChartListView = self.noteChartListView
	local searchLineView = self.searchLineView

	local selectConfig = self.configModel:getConfig("select")
	self.selectConfig = selectConfig

	local navigator = SelectNavigator:new()
	self.navigator = navigator
	navigator.selectModel = self.selectModel
	navigator.view = self

	noteChartSetListView.noteChartSetLibraryModel = self.noteChartSetLibraryModel
	noteChartSetListView.selectModel = self.selectModel

	noteChartListView.noteChartLibraryModel = self.noteChartLibraryModel
	noteChartListView.selectModel = self.selectModel

	-- local scoreListView = ScoreListView:new()
	-- scoreListView.navigator = navigator
	-- scoreListView.config = config
	-- scoreListView.view = self

	-- searchLineView.searchLineModel = self.searchLineModel

	-- local selectMenuView = SelectMenuView:new()
	-- selectMenuView.navigator = navigator
	-- selectMenuView.config = self.config
	-- selectMenuView.view = self
	-- self.selectMenuView = selectMenuView

	local backgroundView = BackgroundView:new()
	self.backgroundView = backgroundView
	backgroundView.view = self

	local sequenceView = self.sequenceView
	sequenceView:setSequenceConfig(self.selectViewConfig)
	sequenceView:setView("NoteChartSetListView", noteChartSetListView)
	sequenceView:setView("NoteChartListView", noteChartListView)
	sequenceView:setView("BackgroundView", backgroundView)
	-- sequenceView:setView("SearchLineView", searchLineView)

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
