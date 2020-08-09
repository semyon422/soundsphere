local Class					= require("aqua.util.Class")
local ScreenManager			= require("sphere.screen.ScreenManager")
local SelectView			= require("sphere.views.SelectView")
local NoteChartModel		= require("sphere.models.NoteChartModel")
local ModifierModel			= require("sphere.models.ModifierModel")
local NoteSkinModel			= require("sphere.models.NoteSkinModel")
local InputModel			= require("sphere.models.InputModel")
local ModifierController	= require("sphere.controllers.ModifierController")

local SelectController = Class:new()

SelectController.construct = function(self)
	self.modifierModel = ModifierModel:new()
	self.noteSkinModel = NoteSkinModel:new()
	self.noteChartModel = NoteChartModel:new()
	self.inputModel = InputModel:new()
	self.view = SelectView:new()
	self.modifierController = ModifierController:new()
end

SelectController.load = function(self)
	local modifierModel = self.modifierModel
	local noteSkinModel = self.noteSkinModel
	local noteChartModel = self.noteChartModel
	local inputModel = self.inputModel
	local view = self.view
	local modifierController = self.modifierController

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
	elseif event.action == "replayNoteChart" then
		if not love.filesystem.exists(event.noteChartEntry.path) then
			return
		end
		if event.noteChartDataEntry.hash == "" then
			return
		end

		local gameplayController
		if event.mode == "result" then
			local FastplayController = require("sphere.controllers.FastplayController")
			gameplayController = FastplayController:new()
		else
			local GameplayController = require("sphere.controllers.GameplayController")
			gameplayController = GameplayController:new()
		end

		local replay = gameplayController.rhythmModel.replayModel:loadReplay(event.scoreEntry.replayHash)

		if replay.modifiers then
			gameplayController.rhythmModel.modifierModel:fromTable(replay.modifiers)
		end
		if event.mode == "replay" or event.mode == "result" then
			gameplayController.rhythmModel.replayModel.replay = replay
			gameplayController.rhythmModel.inputManager:setMode("internal")
			gameplayController.rhythmModel.replayModel:setMode("replay")
		elseif event.mode == "retry" then
			gameplayController.rhythmModel.inputManager:setMode("external")
			gameplayController.rhythmModel.replayModel:setMode("record")
		end

		-- gameplayController.noteChartEntry = event.noteChartEntry
		-- gameplayController.noteChartDataEntry = event.noteChartDataEntry

		if event.mode == "result" then
			gameplayController:play()

			local ResultController = require("sphere.controllers.ResultController")
			local resultController = ResultController:new()

			resultController.scoreSystem = gameplayController.rhythmModel.scoreEngine.scoreSystem
			resultController.noteChart = gameplayController.noteChart
			resultController.noteChartEntry = gameplayController.noteChartEntry
			resultController.noteChartDataEntry = gameplayController.noteChartDataEntry
			resultController.autoplay = gameplayController.rhythmModel.logicEngine.autoplay

			ScreenManager:set(resultController)
		else
			return ScreenManager:set(gameplayController)
		end
	elseif event.name == "setScreen" then
		if event.screenName == "BrowserScreen" then
			return ScreenManager:set(require("sphere.screen.browser.BrowserScreen"))
		elseif event.screenName == "SettingsScreen" then
			return ScreenManager:set(require("sphere.screen.settings.SettingsScreen"))
		end
	end
end

return SelectController
