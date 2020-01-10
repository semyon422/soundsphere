local ModifierButton	= require("sphere.screen.select.ModifierMenu.ModifierButton")
local CheckboxButton	= require("sphere.screen.select.ModifierMenu.CheckboxButton")
local SliderButton		= require("sphere.screen.select.ModifierMenu.SliderButton")
local AddModifierButton	= require("sphere.screen.select.ModifierMenu.AddModifierButton")
local SequenceList		= require("sphere.screen.select.ModifierMenu.SequenceList")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")

local InconsequentialModifierButton = ModifierButton:new()

InconsequentialModifierButton.construct = function(self)
	local Modifier = self.item.Modifier
	local modifier = self.item.modifier
	
	local button
	if Modifier.inconsequential then
		if Modifier.type == "boolean" then
			button = CheckboxButton:new(self)
			button.item = self.item
			button.updateValue = function(self, value)
				modifier.enabled = value
			end
		elseif Modifier.type == "number" then
			button = SliderButton:new(self)
			button.item = self.item
			button.updateValue = function(self, value)
				modifier[modifier.variable] = value
				
				SliderButton.updateValue(self, value)
			end
			button.removeModifier = function(self)
				modifier[modifier.variable] = Modifier[modifier.variable]
			end
		end
	elseif Modifier.sequential then
		if Modifier.type == "number" then
			button = AddModifierButton:new(self)
			button.item = self.item
			button.add = function(self)
				ModifierManager.sequence:add(Modifier)
				SequenceList:reloadItems()
			end
		end
	end
	
	return button
end

return InconsequentialModifierButton
