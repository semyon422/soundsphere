local ModifierButton	= require("sphere.ui.ModifierMenu.ModifierButton")
local CheckboxButton	= require("sphere.ui.ModifierMenu.CheckboxButton")
local SliderButton		= require("sphere.ui.ModifierMenu.SliderButton")
local AddModifierButton	= require("sphere.ui.ModifierMenu.AddModifierButton")
local SequenceList		= require("sphere.ui.ModifierMenu.SequenceList")
-- local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")

local InconsequentialModifierButton = ModifierButton:new()

InconsequentialModifierButton.construct = function(self)
	local Modifier = self.item.Modifier
	local modifier = self.item.modifier
	
	local button
	if Modifier.inconsequential then
		if Modifier.variableType == "boolean" then
			button = CheckboxButton:new(self)
			button.item = self.item
			button.updateValue = function(self, value)
				modifier.enabled = value
			end
		elseif Modifier.variableType == "number" then
			button = SliderButton:new(self)
			button.item = self.item
			button.updateValue = function(self, value)
				modifier[modifier.variableName] = value
				
				SliderButton.updateValue(self, value)
			end
			button.removeModifier = function(self)
				modifier[modifier.variableName] = Modifier[modifier.variableName]
			end
		end
	elseif Modifier.sequential then
		-- if Modifier.variableType == "boolean" then
		-- 	button = AddModifierButton:new(self)
		-- 	button.item = self.item
		-- 	button.add = function(self)
		-- 		ModifierManager.sequence:add(Modifier)
		-- 		SequenceList:reloadItems()
		-- 	end
		-- elseif Modifier.variableType == "number" then
			button = AddModifierButton:new(self)
			button.item = self.item
			button.add = function(self)
				self.list.modifierModel:add(Modifier)
				SequenceList:reloadItems()
			end
		-- end
	end
	
	return button
end

return InconsequentialModifierButton
