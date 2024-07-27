local ListView = require("sphere.views.ListView")
local just = require("just")
local TextCellImView = require("sphere.imviews.TextCellImView")
local SliderView = require("sphere.views.SliderView")
local StepperView = require("sphere.views.StepperView")
local ModifierModel = require("sphere.models.ModifierModel")
local ModifierRegistry = require("sphere.models.ModifierModel.ModifierRegistry")

local ModifierListView = ListView()

ModifierListView.rows = 11

function ModifierListView:reloadItems()
	self.items = self.game.playContext.modifiers
end

---@return number
function ModifierListView:getItemIndex()
	return self.game.modifierSelectModel.modifierIndex
end

---@param count number
function ModifierListView:scroll(count)
	self.game.modifierSelectModel:scrollModifier(count)
end

---@param i number
---@param w number
---@param h number
function ModifierListView:drawItem(i, w, h)
	local modifierSelectModel = self.game.modifierSelectModel

	local item = self.items[i]
	local w2 = w / 2

	local changed, active, hovered = just.button(tostring(item) .. "1", just.is_over(w2, h), 2)
	if changed then
		modifierSelectModel:remove(i)
	end

	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, w, h)
	end
	love.graphics.setColor(1, 1, 1, 1)

	just.row(true)
	just.indent(44)
	TextCellImView(w2 - 44, 72, "left", "", ModifierRegistry:getName(item.id))

	local modifier = ModifierModel:getModifier(item.id)
	if not modifier then
		TextCellImView(w2 - 44, 72, "left", "", "Deleted modifier")
	elseif modifier.defaultValue == nil then
	elseif type(modifier.defaultValue) == "number" then
		just.indent(-w2)
		TextCellImView(w2, 72, "right", "", item.value)

		local value = modifier:toNormValue(item.value)

		local over = SliderView:isOver(w2, h)
		local pos = SliderView:getPosition(w2, h)

		local delta = just.wheel_over(item, over)
		local new_value = just.slider(item, over, pos, value)
		if new_value then
			ModifierModel:setModifierValue(item, modifier:fromNormValue(new_value))
			modifierSelectModel:change()
		elseif delta then
			ModifierModel:increaseModifierValue(item, delta)
			modifierSelectModel:change()
		end
		SliderView:draw(w2, h, value)
	elseif type(modifier.defaultValue) == "string" then
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
			ModifierModel:increaseModifierValue(item, -1)
			modifierSelectModel:change()
		elseif changedRight or delta == 1 then
			ModifierModel:increaseModifierValue(item, 1)
			modifierSelectModel:change()
		end
		StepperView:draw(w2, h, value, count)
	end
	just.row()
end

return ModifierListView
