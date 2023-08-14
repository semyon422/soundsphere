local ListView = require("sphere.views.ListView")
local just = require("just")
local TextCellImView = require("sphere.imviews.TextCellImView")
local SwitchView = require("sphere.views.SwitchView")
local SliderView = require("sphere.views.SliderView")
local StepperView = require("sphere.views.StepperView")

local ModifierListView = ListView()

ModifierListView.rows = 11

function ModifierListView:reloadItems()
	self.items = self.game.modifierModel.config
end

function ModifierListView:getItemIndex()
	return self.game.modifierModel.modifierItemIndex
end

function ModifierListView:scroll(count)
	self.game.modifierModel:scrollModifier(count)
end

function ModifierListView:drawItem(i, w, h)
	local item = self.items[i]
	local w2 = w / 2

	local changed, active, hovered = just.button(tostring(item) .. "1", just.is_over(w2, h), 2)
	if changed then
		self.game.modifierModel:remove(item)
	end

	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, w, h)
	end
	love.graphics.setColor(1, 1, 1, 1)

	just.row(true)
	just.indent(44)
	TextCellImView(w2 - 44, 72, "left", "", item.name)

	local modifier = self.game.modifierModel:getModifier(item)
	if not modifier then
		TextCellImView(w2 - 44, 72, "left", "", "Deleted modifier")
	elseif modifier.interfaceType == "toggle" then
		just.indent((w2 - h) / 2)
		w2 = 72
		local over = SwitchView:isOver(w2, h)
		local delta = just.wheel_over(item, over)
		local changed, active, hovered = just.button(item, over)

		local value = item.value
		if changed then
			value = not value
		elseif delta then
			value = delta == 1
		end
		if changed or delta then
			self.game.modifierModel:setModifierValue(item, value)
		end
		SwitchView:draw(w2, h, value)
	elseif modifier.interfaceType == "slider" then
		just.indent(-w2)
		TextCellImView(w2, 72, "right", "", item.value)

		local value = modifier:toNormValue(item.value)

		local over = SliderView:isOver(w2, h)
		local pos = SliderView:getPosition(w2, h)

		local delta = just.wheel_over(item, over)
		local new_value, active, hovered = just.slider(item, over, pos, value)
		if new_value then
			self.game.modifierModel:setModifierValue(item, modifier:fromNormValue(new_value))
		elseif delta then
			self.game.modifierModel:increaseModifierValue(item, delta)
		end
		SliderView:draw(w2, h, value)
	elseif modifier.interfaceType == "stepper" then
		TextCellImView(w2, 72, "center", "", item.value)
		just.indent(-w2)

		local value = modifier:toIndexValue(item.value)
		local count = modifier:getCount()

		local overAll, overLeft, overRight = StepperView:isOver(w2, h)

		local id = tostring(item)
		local delta = just.wheel_over(id .. "A", overAll)
		local changedLeft = just.button(id .. "L", overLeft)
		local changedRight = just.button(id .. "R", overRight)

		if changedLeft or delta == -1 then
			self.game.modifierModel:increaseModifierValue(item, -1)
		elseif changedRight or delta == 1 then
			self.game.modifierModel:increaseModifierValue(item, 1)
		end
		StepperView:draw(w2, h, value, count)
	end
	just.row()
end

return ModifierListView
