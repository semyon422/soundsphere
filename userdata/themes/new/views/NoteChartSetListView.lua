
local Node = require("aqua.util.Node")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local NoteChartSetListView = Node:new()

NoteChartSetListView.init = function(self)
	local ListView = dofile(self.__path .. "/views/ListView.lua")
	local listView = ListView:new()
	self.listView = listView

	listView.ListItemView = dofile(self.__path .. "/views/NoteChartSetListItemView.lua")
	listView.__path = self.__path
	listView.view = self.view
	listView.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	listView.x = 16 / 9 / 3 / 2
	listView.y = 0
	listView.w = 16 / 9 / 3
	listView.h = 1
	listView.itemCount = 15
	listView.selectedItem = 1

	self:reloadItems()

	self:on("update", function()
		listView.selectedItem = self.selectNavigator.noteChartSetList.selected
		self:reloadItems()
	end)
	listView:on("select", function()
		self.selectNavigator:setNode("noteChartSetList")
		self.view.selectedNode = self
	end)

	self:node(listView)
	self.pass = true
end

NoteChartSetListView.reloadItems = function(self)
	self.listView.items = self.view.noteChartSetLibraryModel:getItems()
end

return NoteChartSetListView
