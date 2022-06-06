local Class = require("aqua.util.Class")

local ModifierController = Class:new()

ModifierController.load = function(self)
	local noteChartModel = self.game.noteChartModel
	local themeModel = self.game.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("ModifierView")
	self.view = view

	view.controller = self
	view.game = self.game

	noteChartModel:load()

	view:load()
end

ModifierController.unload = function(self)
	self.view:unload()
	self.game.multiplayerModel:pushModifiers()
end

ModifierController.update = function(self, dt)
	self.view:update(dt)
end

ModifierController.draw = function(self)
	self.view:draw()
end

ModifierController.receive = function(self, event)
	self.view:receive(event)

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
	elseif event.name == "adjustDifficulty" then
		self:adjustDifficulty()
	elseif event.name == "changeScreen" then
		self.game.screenManager:set(self.selectController)
	end
end

return ModifierController
