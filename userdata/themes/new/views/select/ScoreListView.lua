local viewspackage = (...):match("^(.-%.views%.)")

local Node = require("aqua.util.Node")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local ScoreListItemView = require(viewspackage .. "select.ScoreListItemView")

local ScoreListView = Node:new()

ScoreListView.init = function(self)
	local listView = ListView:new()
	self.listView = listView

	listView.ListItemView = ScoreListItemView
	listView.view = self.view
	listView.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	listView.x = -16 / 9 / 2
	listView.y = 0
	listView.w = 16 / 9 / 3
	listView.h = 1
	listView.itemCount = 15
	listView.selectedItem = 1

	self:reloadItems()

	self:on("update", function()
		listView.selectedItem = self.navigator.scoreList.selected
		self:reloadItems()
	end)
	listView:on("select", function()
		self.navigator:setNode("scoreList")
		self.view.selectedNode = self
	end)
	self:on("draw", self.drawFrame)

	self:node(listView)
	self.pass = true
end

ScoreListView.reloadItems = function(self)
	self.listView.items = self.view.scoreLibraryModel:getItems()
end

ScoreListView.drawFrame = function(self)
	local listView = self.listView
	if self.navigator:checkNode("scoreList") then
		listView.isSelected = true
	else
		listView.isSelected = false
	end
end

return ScoreListView
