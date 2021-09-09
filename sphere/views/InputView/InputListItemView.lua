local viewspackage = (...):match("^(.-%.views%.)")

local ListItemInputView = require(viewspackage .. "ListItemInputView")
local SwitchView = require(viewspackage .. "SwitchView")

local InputListItemView = ListItemInputView:new({construct = false})

InputListItemView.construct = function(self)
	ListItemInputView.construct(self)
	self.switchView = SwitchView:new()
end

InputListItemView.getName = function(self)
	return self.item.virtualKey
end

InputListItemView.getValue = function(self)
	return self.listView.inputModel:getKey(self.listView.inputModeString, self.item.virtualKey)
end

InputListItemView.isActive = function(self)
	local navigator = self.listView.navigator
	return navigator.activeElement == "inputHandler" and navigator.inputItemIndex == self.itemIndex
end

InputListItemView.mousepressed = function(self, event)
	local button = event.args[3]
	if button == 1 then
		self.listView.navigator:setInputHandler(self.itemIndex)
	end
end

return InputListItemView
