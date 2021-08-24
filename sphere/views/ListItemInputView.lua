local viewspackage = (...):match("^(.-%.views%.)")

local ListItemView = require(viewspackage .. "ListItemView")

local ListItemInputView = ListItemView:new()

ListItemInputView.getName = function(self) end
ListItemInputView.getValue = function(self) end
ListItemInputView.isActive = function(self) end

ListItemInputView.draw = function(self)
	ListItemView.draw(self)

	local config = self.listView.config
	self:drawValue(config.name, self:getName())
	if self:isActive() then
		return self:drawValue(config.input.value, "???")
	end
	self:drawValue(config.input.value, self:getValue())
end

ListItemInputView.receive = function(self, event)
	ListItemView.receive(self, event)

	if event.name ~= "mousepressed" then
		return
	end
end

return ListItemInputView
