local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local ModifierNavigator = Navigator:new()

ModifierNavigator.construct = function(self)
	self.modifierItemIndex = 1
	self.availableModifierItemIndex = 1
	self.activeList = "modifierList"
end

ModifierNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event.args[2]
	if self.activeList == "modifierList" then
		if scancode == "up" then self:scrollModifier(-1)
		elseif scancode == "down" then self:scrollModifier(1)
		elseif scancode == "tab" then self.activeList = "availableModifierList"
		elseif scancode == "return" then
		elseif scancode == "backspace" then self:removeModifier()
		elseif scancode == "right" then self:increaseModifierValue(1)
		elseif scancode == "left" then self:increaseModifierValue(-1)
		elseif scancode == "escape" then self:changeScreen("Input")
		end
	elseif self.activeList == "availableModifierList" then
		if scancode == "up" then self:scrollAvailableModifier(-1)
		elseif scancode == "down" then self:scrollAvailableModifier(1)
		elseif scancode == "tab" then self.activeList = "modifierList"
		elseif scancode == "return" then self:addModifier()
		elseif scancode == "escape" then self:changeScreen("Input")
		end
	end
end

ModifierNavigator.changeScreen = function(self, screenName)
	self:send({
		name = "changeScreen",
		screenName = screenName
	})
end

ModifierNavigator.scrollAvailableModifier = function(self, direction, destination)
	local availableModifierList = self.availableModifierList

	local availableModifiers = self.view.modifierModel.modifiers

	direction = direction or destination - availableModifierList.selected
	if not availableModifiers[availableModifierList.selected + direction] then
		return
	end

	availableModifierList.selected = availableModifierList.selected + direction
end

ModifierNavigator.scrollModifier = function(self, direction, destination)
	local modifierList = self.modifierList

	local modifiers = self.config

	direction = direction or destination - modifierList.selected
	if not modifiers[modifierList.selected + direction] then
		return
	end

	modifierList.selected = modifierList.selected + direction
end

ModifierNavigator.fixScrollModifier = function(self)
	local modifierList = self.modifierList

	local modifiers = self.config

	if not modifiers[modifierList.selected] then
		modifierList.selected = #modifiers
	end
end

ModifierNavigator.load1 = function(self)
    Navigator.load(self)

	local availableModifierList = self.availableModifierList
	local modifierList = self.modifierList

	self.node = modifierList
	modifierList:on("up", function()
		self:scrollModifier(-1)
	end)
	modifierList:on("down", function()
		self:scrollModifier(1)
	end)
	modifierList:on("tab", function()
		self.node = availableModifierList
	end)
	modifierList:on("return", function() end)
	modifierList:on("backspace", function(_, itemIndex)
		self:send({
			name = "removeModifier",
			modifierConfig = self.config[itemIndex or modifierList.selected]
		})
		self:fixScrollModifier()
	end)
	modifierList:on("right", function(_, itemIndex)
		local modifierConfig = self.config[itemIndex or modifierList.selected]
		self:send({
			name = "increaseModifierValue",
			modifierConfig = modifierConfig,
			delta = 1
		})
	end)
	modifierList:on("left", function(_, itemIndex)
		local modifierConfig = self.config[itemIndex or modifierList.selected]
		self:send({
			name = "increaseModifierValue",
			modifierConfig = modifierConfig,
			delta = -1
		})
	end)
	modifierList:on("escape", function()
		self:send({
			name = "goSelectScreen"
		})
	end)

	availableModifierList:on("up", function()
		self:scrollAvailableModifier(-1)
	end)
	availableModifierList:on("down", function()
		self:scrollAvailableModifier(1)
	end)
	availableModifierList:on("tab", function()
		self.node = modifierList
	end)
	availableModifierList:on("return", function(_, itemIndex)
		local Modifier = self.view.modifierModel.modifiers[itemIndex or availableModifierList.selected]
		self:send({
			name = "addModifier",
			modifierConfig = Modifier:getDefaultConfig()
		})
	end)
	availableModifierList:on("escape", function()
		self:send({
			name = "goSelectScreen"
		})
	end)
end

return ModifierNavigator
