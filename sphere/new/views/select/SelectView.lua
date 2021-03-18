local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")
local Node = require("aqua.util.Node")

local SelectNavigator = require(viewspackage .. "select.SelectNavigator")
local NoteChartSetListView = require(viewspackage .. "select.NoteChartSetListView")
local NoteChartListView = require(viewspackage .. "select.NoteChartListView")
local ScoreListView = require(viewspackage .. "select.ScoreListView")
local SearchLineView = require(viewspackage .. "select.SearchLineView")
local SelectMenuView = require(viewspackage .. "select.SelectMenuView")
local BackgroundView = require(viewspackage .. "BackgroundView")

local SelectView = Class:new()

SelectView.construct = function(self)
	self.node = Node:new()
end

SelectView.load = function(self)
	local node = self.node
	local config = self.configModel:getConfig("select")

	local navigator = SelectNavigator:new()
	self.navigator = navigator
	navigator.searchLineModel = self.searchLineModel
	navigator.config = config
	navigator.view = self

	local noteChartSetListView = NoteChartSetListView:new()
	noteChartSetListView.navigator = navigator
	noteChartSetListView.config = config
	noteChartSetListView.view = self

	local noteChartListView = NoteChartListView:new()
	noteChartListView.navigator = navigator
	noteChartListView.config = config
	noteChartListView.view = self

	local scoreListView = ScoreListView:new()
	scoreListView.navigator = navigator
	scoreListView.config = config
	scoreListView.view = self

	local searchLineView = SearchLineView:new()
	searchLineView.navigator = navigator
	searchLineView.searchLineModel = self.searchLineModel
	searchLineView.config = self.config
	searchLineView.view = self

	local selectMenuView = SelectMenuView:new()
	selectMenuView.navigator = navigator
	selectMenuView.config = self.config
	selectMenuView.view = self
	self.selectMenuView = selectMenuView

	local backgroundView = BackgroundView:new()
	backgroundView.view = self

	node:node(backgroundView)
	node:node(noteChartSetListView)
	node:node(noteChartListView)
	node:node(scoreListView)
	node:node(searchLineView)
	node:node(selectMenuView)

	navigator:load()
end

SelectView.unload = function(self)
	self.navigator:unload()
end

SelectView.receive = function(self, event)
	-- if event.name == "keypressed" and event.args[1] == "escape" then
	-- 	self.controller:receive({
	-- 		name = "setScreen",
	-- 		screenName = "SelectScreen"
	-- 	})
	-- end
	if event.name == "mousemoved" then
		self.node:callnext("mousemoved", event)
	end
	-- if event.name == "mousepressed" then
	-- 	selectedNode:call("mousepressed", event)
	-- end
	-- if event.name == "wheelmoved" then
	-- 	selectedNode:call("wheelmoved", event.args[2])
	-- end
	-- if event.name == "keypressed" then
	-- 	selectedNode:call("keypressed", event.args[1])
	-- end
	self.navigator:receive(event)
	self.searchLineModel:receive(event)
end

SelectView.update = function(self, dt)
	self.node:callnext("update")
	self.navigator:update()
end

SelectView.draw = function(self)
	self.node:callnext("draw")
end

return SelectView
