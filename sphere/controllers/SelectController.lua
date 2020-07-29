local Class					= require("aqua.util.Class")
local ScreenManager			= require("sphere.screen.ScreenManager")
local SelectView			= require("sphere.views.SelectView")
local NoteChartModel		= require("sphere.models.NoteChartModel")
local ModifierModel			= require("sphere.models.ModifierModel")
local NoteSkinModel			= require("sphere.models.NoteSkinModel")
local InputModel			= require("sphere.models.InputModel")
local ModifierController	= require("sphere.controllers.ModifierController")

local SelectController = Class:new()

SelectController.load = function(self)
	local modifierModel = ModifierModel:new()
	local noteSkinModel = NoteSkinModel:new()
	local noteChartModel = NoteChartModel:new()
	local inputModel = InputModel:new()
	local view = SelectView:new()
	local modifierController = ModifierController:new()

	self.modifierModel = modifierModel
	self.noteSkinModel = noteSkinModel
	self.noteChartModel = noteChartModel
	self.inputModel = inputModel
	self.view = view
	self.modifierController = modifierController

	view.controller = self
	view.noteChartModel = noteChartModel
	view.modifierModel = modifierModel
	view.noteSkinModel = noteSkinModel
	view.inputModel = inputModel

	modifierController.modifierModel = modifierModel

	inputModel:load()
	modifierModel:load()
	noteSkinModel:load()
	noteChartModel:load()

	view:load()
end

SelectController.unload = function(self)
	self.modifierModel:unload()
	self.noteChartModel:unload()
	self.view:unload()
	self.inputModel:unload()
end

SelectController.update = function(self, dt)
	self.view:update(dt)
end

SelectController.draw = function(self)
	self.view:draw()
end

SelectController.receive = function(self, event)
	self.view:receive(event)
	self.modifierController:receive(event)

    if event.name == "setNoteSkin" then
		self.noteSkinModel:setDefaultNoteSkin(event.inputMode, event.metaData)
	elseif event.name == "setInputBinding" then
		self.inputModel:setKey(event.inputMode, event.virtualKey, event.value, event.type)
	elseif event.name == "selectNoteChart" then
		if event.type == "noteChartEntry" then
			self.noteChartModel:selectNoteChart(event.id)
		elseif event.type == "noteChartSetEntry" then
			self.noteChartModel:selectNoteChartSet(event.id)
		end
	elseif event.action == "playNoteChart" then
		if not love.filesystem.exists(event.noteChartEntry.path) then
			return
		end
		if event.noteChartDataEntry.hash == "" then
			return
		end

		local GameplayController = require("sphere.controllers.GameplayController")
		local gameplayController = GameplayController:new()
		gameplayController.noteChartEntry = event.noteChartEntry
		gameplayController.noteChartDataEntry = event.noteChartDataEntry
		return ScreenManager:set(gameplayController)
	elseif event.name == "setScreen" then
		if event.screenName == "BrowserScreen" then
			return ScreenManager:set(require("sphere.screen.browser.BrowserScreen"))
		elseif event.screenName == "SettingsScreen" then
			return ScreenManager:set(require("sphere.screen.settings.SettingsScreen"))
		end
	end
end

return SelectController
