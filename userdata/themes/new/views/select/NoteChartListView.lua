local viewspackage = (...):match("^(.-%.views%.)")

local Node = require("aqua.util.Node")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local NoteChartListItemView = require(viewspackage .. "select.NoteChartListItemView")

local NoteChartListView = Node:new()

NoteChartListView.init = function(self)
	local listView = ListView:new()
	self.listView = listView

	listView.ListItemView = NoteChartListItemView
	listView.view = self.view
	listView.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	listView.x = -16 / 9 / 3 / 2
	listView.y = 0
	listView.w = 16 / 9 / 3
	listView.h = 1
	listView.itemCount = 15
	listView.selectedItem = 1

	self:reloadItems()

	self:on("update", function()
		listView.selectedItem = self.selectNavigator.noteChartList.selected
		self:reloadItems()
	end)
	listView:on("select", function()
		self.selectNavigator:setNode("noteChartList")
		self.view.selectedNode = self
	end)
	self:on("draw", self.drawFrame)

	self:node(listView)
	self.pass = true
end

NoteChartListView.reloadItems = function(self)
	self.listView.items = self.view.noteChartLibraryModel:getItems()
end

NoteChartListView.drawFrame = function(self)
	local listView = self.listView
	if self.selectNavigator:checkNode("noteChartList") then
		listView.isSelected = true
	else
		listView.isSelected = false
	end
end

return NoteChartListView
