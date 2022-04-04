local Class = require("aqua.util.Class")

local ModifierController = Class:new()

ModifierController.load = function(self)
	local noteChartModel = self.gameController.noteChartModel
	local themeModel = self.gameController.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("ModifierView")
	self.view = view

	view.controller = self
	view.gameController = self.gameController

	noteChartModel:load()

	view:load()
end

ModifierController.unload = function(self)
	self.view:unload()
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
		self.gameController.modifierModel:add(event.modifier)
	elseif event.name == "removeModifier" then
		self.gameController.modifierModel:remove(event.modifierConfig)
	elseif event.name == "setModifierValue" then
		self.gameController.modifierModel:setModifierValue(event.modifierConfig, event.value)
	elseif event.name == "increaseModifierValue" then
		self.gameController.modifierModel:increaseModifierValue(event.modifierConfig, event.delta)
	elseif event.name == "scrollModifier" then
		self.gameController.modifierModel:scrollModifier(event.direction)
	elseif event.name == "scrollAvailableModifier" then
		self.gameController.modifierModel:scrollAvailableModifier(event.direction)
	elseif event.name == "adjustDifficulty" then
		self:adjustDifficulty()
	elseif event.name == "changeScreen" then
		self.gameController.screenManager:set(self.selectController)
	end
end

return ModifierController
