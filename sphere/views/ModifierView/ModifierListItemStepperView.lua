local viewspackage = (...):match("^(.-%.views%.)")

local ModifierListItemView = require(viewspackage .. "ModifierView.ModifierListItemView")
local StepperView = require(viewspackage .. "StepperView")

local ModifierListItemStepperView = ModifierListItemView:new()

ModifierListItemStepperView.construct = function(self)
	self.stepperView = StepperView:new()
end

ModifierListItemStepperView.draw = function(self)
	local modifierConfig = self.item

	local modifier = self.listView.view.modifierModel:getModifier(modifierConfig)

	ModifierListItemView.draw(self)

	local config = self.listView.config
	self:drawValue(config.stepper.value)

	local stepperView = self.stepperView
	stepperView:setPosition(self.listView:getItemElementPosition(self.itemIndex, config.stepper))
	stepperView:setValue(modifier:toIndexValue(modifierConfig.value))
	stepperView:setCount(modifier:getCount())
	stepperView:draw()
end

ModifierListItemStepperView.receive = function(self, event)
	ModifierListItemView.receive(self, event)

	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end

	local listView = self.listView

	if listView.activeItem ~= self.itemIndex then
		return
	end

	local config = listView.config
	local stepper = listView.stepper
	local modifierConfig = self.item
	local modifier = listView.view.modifierModel:getModifier(modifierConfig)
	stepper:setPosition(listView:getItemElementPosition(self.itemIndex, config.stepper))
	stepper:setValue(modifier:toIndexValue(modifierConfig.value))
	stepper:setCount(modifier:getCount())
	stepper:receive(event)

	if stepper.valueUpdated then
		self.listView.navigator:setModifierValue(
			modifierConfig,
			modifier:fromIndexValue(stepper.value)
		)
		stepper.valueUpdated = false
	end
end

ModifierListItemStepperView.wheelmoved = function(self, event)
	local x, y, w, h = self.listView:getItemPosition(self.itemIndex)
	local mx, my = love.mouse.getPosition()

	if not (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		return
	end

	x, y, w, h = self.listView:getItemElementPosition(self.itemIndex, self.listView.config.slider)
	if mx >= x and mx <= x + w then
		local wy = event.args[2]
		if wy == 1 then
			self.listView.navigator:increaseModifierValue(self.itemIndex, 1)
		elseif wy == -1 then
			self.listView.navigator:increaseModifierValue(self.itemIndex, -1)
		end
	end
end

return ModifierListItemStepperView
