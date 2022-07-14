local just = require("just")
local ListItemView = require("sphere.views.ListItemView")
local SliderView = require("sphere.views.SliderView")

local ModifierListItemSliderView = ListItemView:new({construct = false})

ModifierListItemSliderView.draw = function(self, w, h)
	ListItemView.draw(self)

	local listView = self.listView
	local item = self.item

	self:drawValue(listView.name, item.name)
	self:drawValue(listView.slider.value, item.value)

	if just.button_behavior(tostring(item) .. "1", just.is_over(w, h), 2) then
		listView.navigator:removeModifier(self.itemIndex)
	end

	local x, y, w, h = listView:getItemElementPosition(listView.slider)
	love.graphics.push()
	love.graphics.translate(x, y)

	local modifier = listView.game.modifierModel:getModifier(item)
	local value = modifier:toNormValue(item.value)

	local over = SliderView:isOver(w, h)
	local pos = SliderView:getPosition(w, h)

	local scrolled, delta = just.wheel_behavior(item, over)
	local changed, value, active, hovered = just.slider_behavior(item, over, pos, value, 0, 1)
	if changed then
		listView.navigator:setModifierValue(item, modifier:fromNormValue(value))
	elseif delta ~= 0 then
		listView.navigator:increaseModifierValue(self.itemIndex, delta)
	end
	SliderView:draw(w, h, value)

	love.graphics.pop()
end

return ModifierListItemSliderView
