local just = require("just")
local ListItemView = require("sphere.views.ListItemView")
local SwitchView = require("sphere.views.SwitchView")

local ModifierListItemSwitchView = ListItemView:new({construct = false})

ModifierListItemSwitchView.draw = function(self, w, h)
	ListItemView.draw(self)

	local listView = self.listView
	local item = self.item

	self:drawValue(listView.name, item.name)

	if just.button_behavior(tostring(item) .. "1", just.is_over(w, h), 2) then
		listView.navigator:removeModifier(self.itemIndex)
	end

	local x, y, w, h = listView:getItemElementPosition(listView.switch)
	love.graphics.push()
	love.graphics.translate(x, y)

	local over = SwitchView:isOver(w, h)
	local scrolled, delta = just.wheel_behavior(item, over)
	local changed, active, hovered = just.button_behavior(item, over)

	local value = item.value
	if changed then
		value = not value
	elseif delta ~= 0 then
		value = delta == 1
	end
	if changed or delta ~= 0 then
		listView.navigator:setModifierValue(item, value)
	end

	SwitchView:draw(w, h, value)

	love.graphics.pop()
end

return ModifierListItemSwitchView
