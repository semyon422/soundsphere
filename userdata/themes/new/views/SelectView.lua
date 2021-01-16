local Class = require("aqua.util.Class")
local Node = require("aqua.util.Node")

local SelectView = Class:new()

SelectView.construct = function(self)
	self.node = Node:new()
	self.selectedNode = Node:new()
end

SelectView.load = function(self)
	local node = self.node
	local config = self.configModel:getConfig("select")

	local SelectNavigator = dofile(self.__path .. "/views/SelectNavigator.lua")
	local selectNavigator = SelectNavigator:new({view = self})
	self.selectNavigator = selectNavigator
	selectNavigator.searchLineModel = self.searchLineModel
	selectNavigator.config = config

	local NoteChartSetListView = dofile(self.__path .. "/views/NoteChartSetListView.lua")
	local noteChartSetListView = NoteChartSetListView:new({__path = self.__path, view = self})
	noteChartSetListView.selectNavigator = selectNavigator
	noteChartSetListView.config = config

	local NoteChartListView = dofile(self.__path .. "/views/NoteChartListView.lua")
	local noteChartListView = NoteChartListView:new({__path = self.__path, view = self})
	noteChartListView.selectNavigator = selectNavigator
	noteChartListView.config = config

	local ScoreListView = dofile(self.__path .. "/views/ScoreListView.lua")
	local scoreListView = ScoreListView:new({__path = self.__path, view = self})
	scoreListView.selectNavigator = selectNavigator
	scoreListView.config = config

	local SearchLineView = dofile(self.__path .. "/views/SearchLineView.lua")
	local searchLineView = SearchLineView:new({__path = self.__path, view = self})
	searchLineView.selectNavigator = selectNavigator
	searchLineView.searchLineModel = self.searchLineModel
	searchLineView.config = self.config

	local BackgroundView = dofile(self.__path .. "/views/BackgroundView.lua")
	local backgroundView = BackgroundView:new({__path = self.__path, view = self})

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
