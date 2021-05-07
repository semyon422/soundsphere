local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local AvailableModifierListItemView = require(viewspackage .. "ModifierView.AvailableModifierListItemView")

local AvailableModifierListView = ListView:new()

AvailableModifierListView.construct = function(self)
	ListView.construct(self)
	self.itemView = AvailableModifierListItemView:new()
	self.itemView.listView = self
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

AvailableModifierListView.forceScroll = function(self)
	self.state.selectedItem = self.modifierModel.availableModifierItemIndex
	self.state.selectedVisualItem = self.modifierModel.availableModifierItemIndex
end

AvailableModifierListView.reloadItems = function(self)
	self.items = self.modifierModel.modifiers
end

AvailableModifierListView.getItemIndex = function(self)
	return self.selectModel.noteChartItemIndex
end

AvailableModifierListView.scrollUp = function(self)
	self.navigator:scrollAvailableModifier("up")
end

AvailableModifierListView.scrollDown = function(self)
	self.navigator:scrollAvailableModifier("down")
end

return AvailableModifierListView
