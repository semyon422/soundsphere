local ListView = require("sphere.views.ListView")

local ModifierListView = ListView:new({construct = false})

ModifierListView.reloadItems = function(self)
	self.items = self.game.modifierModel.config
end

ModifierListView.getItemIndex = function(self)
	return self.game.modifierModel.modifierItemIndex
end

ModifierListView.scroll = function(self, count)
	self.game.modifierModel:scrollModifier(count)
end

return ModifierListView
