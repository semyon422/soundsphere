local ListView = require("sphere.views.ListView")

local ModifierListView = ListView:new({construct = false})

ModifierListView.reloadItems = function(self)
	self.items = self.game.modifierModel.config
end

ModifierListView.getItemIndex = function(self)
	return self.game.modifierModel.modifierItemIndex
end

ModifierListView.scrollUp = function(self)
	self.navigator:scrollModifier("up")
end

ModifierListView.scrollDown = function(self)
	self.navigator:scrollModifier("down")
end

return ModifierListView
