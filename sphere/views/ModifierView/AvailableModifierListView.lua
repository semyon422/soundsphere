local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local AvailableModifierListItemView = require(viewspackage .. "ModifierView.AvailableModifierListItemView")

local AvailableModifierListView = ListView:new({construct = false})

AvailableModifierListView.construct = function(self)
	ListView.construct(self)
	self.itemView = AvailableModifierListItemView:new()
	self.itemView.listView = self
end

AvailableModifierListView.reloadItems = function(self)
	self.state.items = self.gameController.modifierModel.modifiers
end

AvailableModifierListView.getItemIndex = function(self)
	return self.gameController.modifierModel.availableModifierItemIndex
end

AvailableModifierListView.scrollUp = function(self)
	self.navigator:scrollAvailableModifier("up")
end

AvailableModifierListView.scrollDown = function(self)
	self.navigator:scrollAvailableModifier("down")
end

AvailableModifierListView.receive = function(self, event)
	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
	if event.name == "mousepressed" or event.name == "mousereleased" or event.name == "mousemoved" then
		self:receiveItems(event)
	end
end

return AvailableModifierListView
