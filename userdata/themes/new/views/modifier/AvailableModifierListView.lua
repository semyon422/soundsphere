local viewspackage = (...):match("^(.-%.views%.)")

local Node = require("aqua.util.Node")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local AvailableModifierListItemView = require(viewspackage .. "modifier.AvailableModifierListItemView")

local AvailableModifierListView = Node:new()

AvailableModifierListView.init = function(self)
	local listView = ListView:new()
	self.listView = listView

	listView.ListItemView = AvailableModifierListItemView
	listView.view = self.view
	listView.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	listView.x = -16 / 9 / 3
	listView.y = 0
	listView.w = 16 / 9 / 3
	listView.h = 1
	listView.itemCount = 15
	listView.selectedItem = 1

	self:reloadItems()

	self:on("update", function()
		listView.selectedItem = self.navigator.availableModifierList.selected
		self:reloadItems()
	end)
	listView:on("select", function()
		self.navigator:setNode("availableModifierList")
		self.view.selectedNode = self
	end)
	self:on("draw", self.drawFrame)

	self:node(listView)
	self.pass = true
end

AvailableModifierListView.reloadItems = function(self)
	self.listView.items = self.view.modifierModel.modifiers
end

AvailableModifierListView.drawFrame = function(self)
	local listView = self.listView
	if self.navigator:checkNode("availableModifierList") then
		listView.isSelected = true
	else
		listView.isSelected = false
	end
end

return AvailableModifierListView
