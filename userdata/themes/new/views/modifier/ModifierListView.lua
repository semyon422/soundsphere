local viewspackage = (...):match("^(.-%.views%.)")

local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local ModifierListItemView = require(viewspackage .. "modifier.ModifierListItemView")

local ModifierListView = ListView:new()

ModifierListView.init = function(self)
	self.ListItemView = ModifierListItemView
	self.view = self.view
	self.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	self.x = 0
	self.y = 0
	self.w = 16 / 9 / 3
	self.h = 1
	self.itemCount = 15
	self.selectedItem = 1

	self:reloadItems()

	self:on("update", function()
		self.selectedItem = self.navigator.modifierList.selected
		self:reloadItems()
	end)
	self:on("select", function()
		self.navigator:setNode("modifierList")
		self.view.selectedNode = self
	end)
	self:on("draw", self.drawFrame)

	ListView.init(self)
end

ModifierListView.reloadItems = function(self)
	self.items = self.view.configModel:getConfig("modifier")
end

ModifierListView.drawFrame = function(self)
	if self.navigator:checkNode("modifierList") then
		self.isSelected = true
	else
		self.isSelected = false
	end
end

return ModifierListView
