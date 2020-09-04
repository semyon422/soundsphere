local Class = require("aqua.util.Class")

local ModifierController = Class:new()

ModifierController.receive = function(self, event)
	if event.name == "enableBooleanModifier" then
		event.modifier.enabled = event.value
	elseif event.name == "enableNumberModifier" then
		event.modifier[event.modifier.variableName] = event.value
	elseif event.name == "disableNumberModifier" then
		event.modifier[event.modifier.variableName] = event.Modifier[event.modifier.variableName]
	elseif event.name == "addModifier" then
		self.modifierModel:add(event.Modifier)
	elseif event.name == "removeModifier" then
		self.modifierModel:remove(event.modifier)
    end
end

return ModifierController
