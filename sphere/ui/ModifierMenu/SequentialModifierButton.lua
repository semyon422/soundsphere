local ModifierButton	= require("sphere.ui.ModifierMenu.ModifierButton")
local TextButton		= require("sphere.ui.ModifierMenu.TextButton")
local SliderButton		= require("sphere.ui.ModifierMenu.SliderButton")

local SequentialModifierButton = ModifierButton:new()

SequentialModifierButton.construct = function(self)
	local Modifier = self.item.Modifier
	local modifier = self.item.modifier

	local button
	if Modifier.variableType == "boolean" then
		button = TextButton:new(self)
		button.item = self.item
		button.updateValue = function(self, value) end
		button.removeModifier = function(self)
			self.list.menu.observable:send({
				name = "removeModifier",
				modifier = modifier
			})

			local SequenceList = require("sphere.ui.ModifierMenu.SequenceList")
			SequenceList:reloadItems()
		end
	elseif Modifier.variableType == "number" then
		button = SliderButton:new(self)
		button.item = self.item
		button.updateValue = function(self, value)
			self.list.menu.observable:send({
				name = "updateNumberModifier",
				modifier = modifier,
				value = value
			})

			SliderButton.updateValue(self, value)
		end
		button.removeModifier = function(self)
			self.list.menu.observable:send({
				name = "removeModifier",
				modifier = modifier
			})

			local SequenceList = require("sphere.ui.ModifierMenu.SequenceList")
			SequenceList:reloadItems()
		end
	end

	return button
end

return SequentialModifierButton
