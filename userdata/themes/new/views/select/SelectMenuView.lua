local viewspackage = (...):match("^(.-%.views%.)")

local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local SelectMenuItemView = require(viewspackage .. "select.SelectMenuItemView")

local SelectMenuView = ListView:new()

SelectMenuView.init = function(self)
	self.ListItemView = SelectMenuItemView
	self.view = self.view
	self.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	self.x = -16 / 9 / 3 / 2
	self.y = 14 / 15
	self.w = 16 / 9 / 3
	self.h = 1 / 15
	self.selectedItem = 1

	self:reloadItems()
	self.itemCount = #self.items

	self:on("update", function()
		self.selectedItem = self.navigator.selectMenu.selected
	end)
	self:on("select", function()
		self.navigator:setNode("selectMenu")
	end)
	self:on("draw", self.drawFrame)
	self:on("mousemoved", self.receive)

	ListView.init(self)
end

SelectMenuView.reloadItems = function(self)
	self.items = {
		{
			name = "modifiers",
			controllerName = "ModifierController"
		},
		{
			name = "noteskins",
			controllerName = "NoteSkinController"
		},
		{
			name = "keybinds",
		},
	}
end

SelectMenuView.drawFrame = function(self)
	if self.navigator:checkNode("selectMenu") then
		self.isSelected = true
	else
		self.isSelected = false
	end
end

SelectMenuView.draw = function(self)
	for i = 1, self.itemCount do
		local item = self.items[i]
		if item then
			local listItemView = self:getListItemView(item)
			listItemView.itemIndex = i
			listItemView.item = item
			listItemView:draw()
		end
	end
end

SelectMenuView.receive = function(self, event)
	for i = 1, self.itemCount do
		local item = self.items[i]
		if item then
			local listItemView = self:getListItemView(item)
			listItemView.itemIndex = i
			listItemView.item = item
			listItemView:receive(event)
		end
	end
end

return SelectMenuView
