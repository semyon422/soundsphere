
local Node = require("aqua.util.Node")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local ScoreListView = Node:new()

ScoreListView.init = function(self)
	local ListView = dofile(self.__path .. "/views/ListView.lua")
	local listView = ListView:new()
	self.listView = listView

	listView.ListItemView = dofile(self.__path .. "/views/ScoreListItemView.lua")
	listView.__path = self.__path
	listView.view = self.view
	listView.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	listView.x = -16 / 9 / 2
	listView.y = 0
	listView.w = 16 / 9 / 3
	listView.h = 1
	listView.itemCount = 17
	listView.selectedItem = 1

	self:reloadItems()

	self:on("update", function()
		listView.selectedItem = self.selectNavigator.scoreList.selected
		self:reloadItems()
	end)
	listView:on("select", function()
		self.selectNavigator:setNode("scoreList")
		self.view.selectedNode = self
	end)

	self:node(listView)
	self.pass = true
end

ScoreListView.reloadItems = function(self)
	self.listView.items = self.view.scoreLibraryModel:getItems()
end

return ScoreListView
