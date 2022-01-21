local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local ModifierNavigator = Navigator:new({construct = false})

ModifierNavigator.construct = function(self)
	Navigator.construct(self)
	self.activeList = "modifierList"
end

ModifierNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event.args[2]
	if self.activeList == "modifierList" then
		if scancode == "up" then self:scrollModifier("up")
		elseif scancode == "down" then self:scrollModifier("down")
		elseif scancode == "tab" then self.activeList = "availableModifierList"
		elseif scancode == "return" then
		elseif scancode == "backspace" then self:removeModifier()
		elseif scancode == "right" then self:increaseModifierValue(nil, 1)
		elseif scancode == "left" then self:increaseModifierValue(nil, -1)
		elseif scancode == "escape" then self:changeScreen("Select")
		elseif scancode == "f1" then self:switchSubscreen("debug")
		end
	elseif self.activeList == "availableModifierList" then
		if scancode == "up" then self:scrollAvailableModifier("up")
		elseif scancode == "down" then self:scrollAvailableModifier("down")
		elseif scancode == "tab" then self.activeList = "modifierList"
		elseif scancode == "return" then self:addModifier()
		elseif scancode == "escape" then self:changeScreen("Select")
		elseif scancode == "f1" then self:switchSubscreen("debug")
		end
	end
end

ModifierNavigator.scrollModifier = function(self, direction)
	direction = direction == "up" and -1 or 1
	self:send({
		name = "scrollModifier",
		direction = direction
	})
end

ModifierNavigator.scrollAvailableModifier = function(self, direction)
	direction = direction == "up" and -1 or 1
	self:send({
		name = "scrollAvailableModifier",
		direction = direction
	})
end

ModifierNavigator.removeModifier = function(self, itemIndex)
	local modifierConfig = self.gameController.modifierModel.config[itemIndex or self.gameController.modifierModel.modifierItemIndex]
	if not modifierConfig then
		return
	end
	self:send({
		name = "removeModifier",
		modifierConfig = modifierConfig
	})
end

ModifierNavigator.increaseModifierValue = function(self, itemIndex, delta)
	local modifierConfig = self.gameController.modifierModel.config[itemIndex or self.gameController.modifierModel.modifierItemIndex]
	if not modifierConfig then
		return
	end
	self:send({
		name = "increaseModifierValue",
		modifierConfig = modifierConfig,
		delta = delta
	})
end

ModifierNavigator.addModifier = function(self, itemIndex)
	local modifier = self.gameController.modifierModel.modifiers[itemIndex or self.gameController.modifierModel.availableModifierItemIndex]
	self:send({
		name = "addModifier",
		modifier = modifier
	})
end

ModifierNavigator.setModifierValue = function(self, modifierConfig, value)
	self:send({
		name = "setModifierValue",
		modifierConfig = modifierConfig,
		value = value
	})
end

return ModifierNavigator
