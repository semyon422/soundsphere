
local Node = require("aqua.util.Node")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local NoteChartListView = Node:new()

NoteChartListView.init = function(self)
	local ListView = dofile(self.__path .. "/views/ListView.lua")
	local listView = ListView:new()
	self.listView = listView

	listView.__path = self.__path
	listView.view = self.view
	listView.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	listView.x = -16 / 9 / 3 / 2
	listView.y = 0
	listView.w = 16 / 9 / 3
	listView.h = 1
	listView.itemCount = 17
	listView.selectedItem = 1

	self.selectedSet = 1
	self.setId = 1

	self:reloadItems()

	self:on("update", function()
		listView.selectedItem = self.selectNavigator.noteChartList.selected

		local oldSelected = self.selectedSet
		local newSelected = self.selectNavigator.noteChartSetList.selected
		if oldSelected ~= newSelected then
			self.setId = self.noteChartSetListView.listView.items[newSelected].noteChartSetEntry.id
			self:reloadItems()
		end
		self.selectedSet = newSelected
	end)
	listView:on("select", function()
		self.selectNavigator:setNode("noteChartList")
		self.view.selectedNode = self
	end)

	self:node(listView)
	self.pass = true
end

NoteChartListView.reloadItems = function(self)
	self.listView.items = self.view.noteChartLibraryModel:getItems(self.setId, "")
end

return NoteChartListView
