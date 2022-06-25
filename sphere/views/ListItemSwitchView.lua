local ListItemView = require("sphere.views.ListItemView")
local SwitchView = require("sphere.views.SwitchView")
local just = require("just")

local ListItemSwitchView = ListItemView:new({construct = false})

ListItemSwitchView.construct = function(self)
	ListItemView.construct(self)
	self.switchView = SwitchView:new()
end

ListItemSwitchView.getName = function(self) end
ListItemSwitchView.getValue = function(self) end
ListItemSwitchView.setValue = function(self, delta) end

ListItemSwitchView.draw = function(self)
	ListItemView.draw(self)

	local listView = self.listView
	self:drawValue(listView.name, self:getName())

	local switchView = self.switchView
	local x, y, w, h = listView:getItemElementPosition(listView.switch)
	love.graphics.push()
	love.graphics.translate(x, y)

	local value = self:getValue()
	local over = switchView:isOver(w, h)

	local scrolled, delta = just.wheel_behavior(self.item, over)
	local changed, active, hovered = just.button_behavior(self.item, over)
	if changed then
		value = not value
		self:setValue(value)
	elseif delta ~= 0 then
		self:setValue(delta == 1)
	end
	switchView:draw(w, h, value)

	love.graphics.pop()
end

return ListItemSwitchView
