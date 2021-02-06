local viewspackage = (...):match("^(.-%.views%.)")

local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local AvailableModifierListItemView = require(viewspackage .. "modifier.AvailableModifierListItemView")

local AvailableModifierListView = ListView:new()

AvailableModifierListView.init = function(self)
	self.ListItemView = AvailableModifierListItemView
	self.view = self.view
	self.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	self.x = -16 / 9 / 3
	self.y = 0
	self.w = 16 / 9 / 3
	self.h = 1
	self.itemCount = 15
	self.selectedItem = 1

	self:reloadItems()

	self:on("update", function()
		self.selectedItem = self.navigator.availableModifierList.selected
		self:reloadItems()
	end)
	self:on("select", function()
		self.navigator:setNode("availableModifierList")
		self.view.selectedNode = self
	end)
	self:on("draw", self.drawFrame)
	self:on("wheelmoved", function(self, event)
		local y = event.args[2]
		if y == 1 then
			self.navigator:call("up")
		elseif y == -1 then
			self.navigator:call("down")
		end
	end)
	self:on("mousepressed", function(self, event)
		local button = event.args[3]
		if button == 1 then
			self.navigator:call("return")
		end
	end)

	ListView.init(self)
end

AvailableModifierListView.reloadItems = function(self)
	self.items = self.view.modifierModel.modifiers
end

AvailableModifierListView.drawFrame = function(self)
	if self.navigator:checkNode("availableModifierList") then
		self.isSelected = true
	else
		self.isSelected = false
	end
end

return AvailableModifierListView
