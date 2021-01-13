local Class = require("aqua.util.Class")
local Node = require("aqua.util.Node")

local SelectView = Class:new()

SelectView.construct = function(self)
	self.node = Node:new()
	self.selectedNode = Node:new()
end

SelectView.load = function(self)
	local node = self.node

	local SelectNavigator = dofile(self.__path .. "/views/SelectNavigator.lua")
	local selectNavigator = SelectNavigator:new({view = self})
	self.selectNavigator = selectNavigator

	local NoteChartSetListView = dofile(self.__path .. "/views/NoteChartSetListView.lua")
	local noteChartSetListView = NoteChartSetListView:new({__path = self.__path, view = self})
	noteChartSetListView.selectNavigator = selectNavigator

	local NoteChartListView = dofile(self.__path .. "/views/NoteChartListView.lua")
	local noteChartListView = NoteChartListView:new({__path = self.__path, view = self})
	noteChartListView.selectNavigator = selectNavigator

	local ScoreListView = dofile(self.__path .. "/views/ScoreListView.lua")
	local scoreListView = ScoreListView:new({__path = self.__path, view = self})
	scoreListView.selectNavigator = selectNavigator

	noteChartListView.noteChartSetListView = noteChartSetListView
	noteChartSetListView.noteChartListView = noteChartListView
	scoreListView.noteChartListView = noteChartListView

	node:node(noteChartSetListView)
	node:node(noteChartListView)
	node:node(scoreListView)

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
end

SelectView.update = function(self, dt)
	self.node:callnext("update")
end

SelectView.draw = function(self)
	self.node:callnext("draw")
end

return SelectView
