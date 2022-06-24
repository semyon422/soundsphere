local Navigator = require("sphere.views.Navigator")

local ModifierNavigator = Navigator:new({construct = false})

ModifierNavigator.construct = function(self)
	Navigator.construct(self)
	self.activeList = "modifierList"
end

ModifierNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event[2]
	if self.activeList == "modifierList" then
		if scancode == "up" then self:scrollModifier("up")
		elseif scancode == "down" then self:scrollModifier("down")
		elseif scancode == "tab" then self.activeList = "availableModifierList"
		elseif scancode == "return" then
		elseif scancode == "backspace" then self:removeModifier()
		elseif scancode == "right" then self:increaseModifierValue(nil, 1)
		elseif scancode == "left" then self:increaseModifierValue(nil, -1)
		elseif scancode == "escape" then self:changeScreen("selectView")
		elseif scancode == "f1" then self:switchSubscreen("debug")
		end
	elseif self.activeList == "availableModifierList" then
		if scancode == "up" then self:scrollAvailableModifier("up")
		elseif scancode == "down" then self:scrollAvailableModifier("down")
		elseif scancode == "tab" then self.activeList = "modifierList"
		elseif scancode == "return" then self:addModifier()
		elseif scancode == "escape" then self:changeScreen("selectView")
		elseif scancode == "f1" then self:switchSubscreen("debug")
		end
	end
end

ModifierNavigator.scrollModifier = function(self, direction)
	self.game.modifierModel:scrollModifier(direction == "up" and -1 or 1)
end

ModifierNavigator.scrollAvailableModifier = function(self, direction)
	self.game.modifierModel:scrollAvailableModifier(direction == "up" and -1 or 1)
end

ModifierNavigator.removeModifier = function(self, itemIndex)
	local modifierConfig = self.game.modifierModel.config[itemIndex or self.game.modifierModel.modifierItemIndex]
	if not modifierConfig then
		return
	end
	self.game.modifierModel:remove(modifierConfig)
end

ModifierNavigator.increaseModifierValue = function(self, itemIndex, delta)
	local modifierConfig = self.game.modifierModel.config[itemIndex or self.game.modifierModel.modifierItemIndex]
	if not modifierConfig then
		return
	end
	self.game.modifierModel:increaseModifierValue(modifierConfig, delta)
end

ModifierNavigator.addModifier = function(self, itemIndex)
	local modifier = self.game.modifierModel.modifiers[itemIndex or self.game.modifierModel.availableModifierItemIndex]
	self.game.modifierModel:add(modifier)
end

ModifierNavigator.setModifierValue = function(self, modifierConfig, value)
	self.game.modifierModel:setModifierValue(modifierConfig, value)
end

return ModifierNavigator
