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
	modifierList:on("return", function()
		self:send({
			name = "playNoteChart",
		})
	end)
	modifierList:on("backspace", function()
		self:send({
			name = "removeModifier",
			modifierConfig = self.config[modifierList.selected]
		})
	end)
	modifierList:on("right", function()
		local modifierConfig = self.config[modifierList.selected]
		self:send({
			name = "setModifierValue",
			modifierConfig = modifierConfig,
			value = modifierConfig.value + 1
		})
	end)
	modifierList:on("left", function()
		local modifierConfig = self.config[modifierList.selected]
		self:send({
			name = "setModifierValue",
			modifierConfig = modifierConfig,
			value = modifierConfig.value - 1
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
	availableModifierList:on("return", function()
		local Modifier = self.view.modifierModel.modifiers[availableModifierList.selected]
		self:send({
			name = "addModifier",
			modifierConfig = Modifier:getDefaultConfig()
		})
	end)
end

ModifierNavigator.receive = function(self, event)
	if event.name == "wheelmoved" then
		local y = event.args[2]
		if y == 1 then
			self:call("up")
		elseif y == -1 then
			self:call("down")
		end
	elseif event.name == "mousepressed" then
		self:call("return")
	elseif event.name == "keypressed" then
		self:call(event.args[1])
	end
end

return ModifierNavigator
