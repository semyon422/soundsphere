local just = require("just")
local ListItemView = require("sphere.views.ListItemView")
local StepperView = require("sphere.views.StepperView")

local ModifierListItemStepperView = ListItemView:new({construct = false})

ModifierListItemStepperView.draw = function(self, w, h)
	ListItemView.draw(self)

	local listView = self.listView
	local item = self.item

	self:drawValue(listView.name, item.name)
	self:drawValue(listView.stepper.value, item.value)

	if just.button_behavior(tostring(item) .. "1", just.is_over(w, h), 2) then
		listView.navigator:removeModifier(self.itemIndex)
	end

	local x, y, w, h = listView:getItemElementPosition(listView.stepper)
	love.graphics.push()
	love.graphics.translate(x, y)

	local modifier = listView.game.modifierModel:getModifier(item)
	local value =  modifier:toIndexValue(item.value)
	local count = modifier:getCount()

	local overAll, overLeft, overRight = StepperView:isOver(w, h)

	local id = tostring(item)
	local scrolled, delta = just.wheel_behavior(id .. "A", overAll)
	local changedLeft = just.button_behavior(id .. "L", overLeft)
	local changedRight = just.button_behavior(id .. "R", overRight)

	if changedLeft or delta == -1 then
		listView.navigator:increaseModifierValue(self.itemIndex, -1)
	elseif changedRight or delta == 1 then
		listView.navigator:increaseModifierValue(self.itemIndex, 1)
	end
	StepperView:draw(w, h, value, count)

	love.graphics.pop()
end

return ModifierListItemStepperView
