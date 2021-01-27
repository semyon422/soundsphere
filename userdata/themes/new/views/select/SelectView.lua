local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")
local Node = require("aqua.util.Node")

local SelectNavigator = require(viewspackage .. "select.SelectNavigator")
local NoteChartSetListView = require(viewspackage .. "select.NoteChartSetListView")
local NoteChartListView = require(viewspackage .. "select.NoteChartListView")
local ScoreListView = require(viewspackage .. "select.ScoreListView")
local SearchLineView = require(viewspackage .. "select.SearchLineView")
local BackgroundView = require(viewspackage .. "BackgroundView")

local SelectView = Class:new()

SelectView.construct = function(self)
	self.node = Node:new()
	self.selectedNode = Node:new()
end

SelectView.load = function(self)
	local node = self.node
	local config = self.configModel:getConfig("select")

	local selectNavigator = SelectNavigator:new()
	self.selectNavigator = selectNavigator
	selectNavigator.searchLineModel = self.searchLineModel
	selectNavigator.config = config
	selectNavigator.view = self

	local noteChartSetListView = NoteChartSetListView:new()
	noteChartSetListView.selectNavigator = selectNavigator
	noteChartSetListView.config = config
	noteChartSetListView.view = self

	local noteChartListView = NoteChartListView:new()
	noteChartListView.selectNavigator = selectNavigator
	noteChartListView.config = config
	noteChartListView.view = self

	local scoreListView = ScoreListView:new()
	scoreListView.selectNavigator = selectNavigator
	scoreListView.config = config
	scoreListView.view = self

	local searchLineView = SearchLineView:new()
	searchLineView.selectNavigator = selectNavigator
	searchLineView.searchLineModel = self.searchLineModel
	searchLineView.config = self.config
	searchLineView.view = self

	local backgroundView = BackgroundView:new()
	backgroundView.view = self

	node:node(backgroundView)
	node:node(noteChartSetListView)
	node:node(noteChartListView)
	node:node(scoreListView)
	node:node(searchLineView)

	self.selectedNode = node

	selectNavigator:load()
end

SelectView.unload = function(self)
	self.selectNavigator:unload()
end

SelectView.receive = function(self, event)
	local selectedNode = self.selectedNode
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
	self.selectNavigator:receive(event)
	self.searchLineModel:receive(event)
end

SelectView.update = function(self, dt)
	self.node:callnext("update")
	self.selectNavigator:update()
end

SelectView.draw = function(self)
	self.node:callnext("draw")
end

return SelectView
