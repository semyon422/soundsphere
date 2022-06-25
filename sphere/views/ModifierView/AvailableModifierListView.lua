local ListView = require("sphere.views.ListView")
local AvailableModifierListItemView = require("sphere.views.ModifierView.AvailableModifierListItemView")

local AvailableModifierListView = ListView:new({construct = false})

AvailableModifierListView.construct = function(self)
	ListView.construct(self)
	self.itemView = AvailableModifierListItemView:new()
	self.itemView.listView = self
end

AvailableModifierListView.reloadItems = function(self)
	self.items = self.game.modifierModel.modifiers
end

AvailableModifierListView.getItemIndex = function(self)
	return self.game.modifierModel.availableModifierItemIndex
end

AvailableModifierListView.scrollUp = function(self)
	self.navigator:scrollAvailableModifier("up")
end

AvailableModifierListView.scrollDown = function(self)
	self.navigator:scrollAvailableModifier("down")
end

return AvailableModifierListView
