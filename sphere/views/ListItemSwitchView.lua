local ListItemView = require("sphere.views.ListItemView")
local ListItemSliderView = require("sphere.views.ListItemSliderView")
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
	local x, y, w, h = listView:getItemElementPosition(self.itemIndex, listView.switch)
	love.graphics.push()
	love.graphics.translate(x, y)

	local value = self:getValue()

	local changed, active, hovered = just.button_behavior(self.item, switchView:isOver(w, h))
	if changed then
		value = not value
		self:setValue(value)
	end
	switchView:draw(w, h, value)

	love.graphics.pop()
end

ListItemSwitchView.receive = function(self, event)
	ListItemView.receive(self, event)

	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
end

ListItemSwitchView.increaseValue = function(self, delta)
	if delta == 1 then
		self:setValue(true)
	elseif delta == -1 then
		self:setValue(false)
	end
end

ListItemSwitchView.wheelmoved = ListItemSliderView.wheelmoved

return ListItemSwitchView
