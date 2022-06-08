local Class = require("aqua.util.Class")

local ModifierController = Class:new()

ModifierController.load = function(self)
	local noteChartModel = self.game.noteChartModel
	noteChartModel:load()
end

ModifierController.unload = function(self)
	self.game.multiplayerModel:pushModifiers()
end

ModifierController.update = function(self, dt) end

ModifierController.draw = function(self) end

ModifierController.receive = function(self, event)
	if event.name == "addModifier" then
		self.game.modifierModel:add(event.modifier)
	elseif event.name == "removeModifier" then
		self.game.modifierModel:remove(event.modifierConfig)
	elseif event.name == "setModifierValue" then
		self.game.modifierModel:setModifierValue(event.modifierConfig, event.value)
	elseif event.name == "increaseModifierValue" then
		self.game.modifierModel:increaseModifierValue(event.modifierConfig, event.delta)
	elseif event.name == "scrollModifier" then
		self.game.modifierModel:scrollModifier(event.direction)
	elseif event.name == "scrollAvailableModifier" then
		self.game.modifierModel:scrollAvailableModifier(event.direction)
	end
end

return ModifierController
