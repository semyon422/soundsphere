local Screen			= require("sphere.screen.Screen")
local SelectView		= require("sphere.views.SelectView")
local SelectController	= require("sphere.controllers.SelectController")
local NoteChartModel	= require("sphere.models.NoteChartModel")
local ModifierModel		= require("sphere.models.ModifierModel")
local NoteSkinModel		= require("sphere.models.NoteSkinModel")
local InputModel		= require("sphere.models.InputModel")

local SelectScreen = Screen:new()

SelectScreen.load = function(self)
	local modifierModel = ModifierModel:new()
	local noteSkinModel = NoteSkinModel:new()
	local noteChartModel = NoteChartModel:new()
	local inputModel = InputModel:new()
	local view = SelectView:new()
	local controller = SelectController:new()

	self.modifierModel = modifierModel
	self.noteSkinModel = noteSkinModel
	self.noteChartModel = noteChartModel
	self.inputModel = inputModel
	self.view = view
	self.controller = controller

	view.controller = controller
	view.noteChartModel = noteChartModel
	view.modifierModel = modifierModel
	view.noteSkinModel = noteSkinModel
	view.inputModel = inputModel

	controller.view = view
	controller.noteChartModel = noteChartModel
	controller.noteSkinModel = noteSkinModel
	controller.inputModel = inputModel

	inputModel:load()
	modifierModel:load()
	noteSkinModel:load()
	noteChartModel:load()

	view:load()
	controller:load()
end

SelectScreen.unload = function(self)
	self.modifierModel:unload()
	self.noteChartModel:unload()
	self.view:unload()
	self.inputModel:unload()
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
