local ListView = require("sphere.views.ListView")

local AvailableModifierListView = ListView:new({construct = false})

AvailableModifierListView.reloadItems = function(self)
	self.items = self.game.modifierModel.modifiers
end

AvailableModifierListView.getItemIndex = function(self)
	return self.game.modifierModel.availableModifierItemIndex
end

AvailableModifierListView.scroll = function(self, count)
	self.game.modifierModel:scrollAvailableModifier(count)
end

return AvailableModifierListView
