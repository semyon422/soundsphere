local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")
local Node = require("aqua.util.Node")

local ModifierNavigator = Navigator:new()

ModifierNavigator.construct = function(self)
	Navigator.construct(self)

	local availableModifierList = Node:new()
	self.availableModifierList = availableModifierList
	availableModifierList.selected = 1

	local modifierList = Node:new()
	self.modifierList = modifierList
	modifierList.selected = 1
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

ModifierNavigator.load = function(self)
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

ModifierNavigator.receive = function(self, event)
	if event.name == "keypressed" then
		self:call(event.args[1])
	end
end

return ModifierNavigator
