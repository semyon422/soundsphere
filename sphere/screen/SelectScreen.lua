local Screen			= require("sphere.screen.Screen")
local SelectView		= require("sphere.views.SelectView")
local SelectController	= require("sphere.controllers.SelectController")
local NoteChartModel	= require("sphere.models.NoteChartModel")
local ModifierModel		= require("sphere.models.ModifierModel")

local SelectScreen = Screen:new()

SelectScreen.load = function(self)
	local modifierModel = ModifierModel:new()
	local noteChartModel = NoteChartModel:new()
	local view = SelectView:new()
	local controller = SelectController:new()

	self.modifierModel = modifierModel
	self.noteChartModel = noteChartModel
	self.view = view
	self.controller = controller

	view.controller = controller
	view.noteChartModel = noteChartModel
	view.modifierModel = modifierModel

	controller.view = view
	controller.noteChartModel = noteChartModel

	modifierModel:load()
	noteChartModel:load()

	view:load()
	controller:load()
end

SelectScreen.unload = function(self)
	self.modifierModel:unload()
	self.noteChartModel:unload()
	self.view:unload()
end

SelectScreen.update = function(self, dt)
	self.view:update(dt)
end

SelectScreen.draw = function(self)
	self.view:draw()
end

SelectScreen.receive = function(self, event)
	self.view:receive(event)
	-- self.controller:receive(event)
end

return SelectScreen
