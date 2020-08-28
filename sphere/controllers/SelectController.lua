local Class					= require("aqua.util.Class")
local ScreenManager			= require("sphere.screen.ScreenManager")
local SelectView			= require("sphere.views.SelectView")
local NoteChartModel		= require("sphere.models.NoteChartModel")
local ModifierModel			= require("sphere.models.ModifierModel")
local NoteSkinModel			= require("sphere.models.NoteSkinModel")
local InputModel			= require("sphere.models.InputModel")
local CacheModel			= require("sphere.models.CacheModel")
local ModifierController	= require("sphere.controllers.ModifierController")

local SelectController = Class:new()

SelectController.construct = function(self)
	self.modifierModel = ModifierModel:new()
	self.noteSkinModel = NoteSkinModel:new()
	self.noteChartModel = NoteChartModel:new()
	self.inputModel = InputModel:new()
	self.cacheModel = CacheModel:new()
	self.view = SelectView:new()
	self.modifierController = ModifierController:new()
end

SelectController.load = function(self)
	local modifierModel = self.modifierModel
	local noteSkinModel = self.noteSkinModel
	local noteChartModel = self.noteChartModel
	local inputModel = self.inputModel
	local cacheModel = self.cacheModel
	local view = self.view
	local modifierController = self.modifierController
	local configModel = self.configModel
	local mountModel = self.mountModel

	noteChartModel.cacheModel = cacheModel
	noteSkinModel.configModel = configModel

	view.controller = self
	view.noteChartModel = noteChartModel
	view.modifierModel = modifierModel
	view.noteSkinModel = noteSkinModel
	view.inputModel = inputModel
	view.cacheModel = cacheModel
	view.configModel = configModel
	view.mountModel = mountModel

	modifierController.modifierModel = modifierModel

	inputModel:load()
	modifierModel:load()
	noteSkinModel:load()
	cacheModel:load()
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
		self:playNoteChart(event)
	elseif event.name == "loadModifiedNoteChart" then
		self:loadModifiedNoteChart()
	elseif event.name == "resetModifiedNoteChart" then
		self:resetModifiedNoteChart()
	elseif event.action == "replayNoteChart" then
		self:replayNoteChart(event)
	elseif event.name == "setScreen" then
		if event.screenName == "BrowserScreen" then
			local BrowserController = require("sphere.controllers.BrowserController")
			local browserController = BrowserController:new()
			browserController.configModel = self.configModel
			browserController.cacheModel = self.cacheModel
			browserController.selectController = self
			return ScreenManager:set(browserController)
		elseif event.screenName == "SettingsScreen" then
			local SettingsController = require("sphere.controllers.SettingsController")
			local settingsController = SettingsController:new()
			settingsController.configModel = self.configModel
			settingsController.selectController = self
			return ScreenManager:set(settingsController)
		end
	end
end

SelectController.resetModifiedNoteChart = function(self)
	local noteChartModel = self.noteChartModel
	local modifierModel = self.modifierModel

	local noteChart = noteChartModel:loadNoteChart()

	modifierModel.noteChart = noteChart
	modifierModel:apply("NoteChartModifier")
end

SelectController.loadModifiedNoteChart = function(self)
	if not self.noteChartModel.noteChart then
		self:resetModifiedNoteChart()
	end
end

SelectController.playNoteChart = function(self)
	local noteChartModel = self.noteChartModel
	local info = love.filesystem.getInfo(noteChartModel.noteChartEntry.path)
	if not info then
		return
	end

	local GameplayController = require("sphere.controllers.GameplayController")
	local gameplayController = GameplayController:new()
	gameplayController.noteChartModel = noteChartModel
	gameplayController.modifierModel = self.modifierModel
	gameplayController.configModel = self.configModel
	gameplayController.selectController = self
	return ScreenManager:set(gameplayController)
end

SelectController.replayNoteChart = function(self, event)
	local noteChartModel = self.noteChartModel
	local info = love.filesystem.getInfo(noteChartModel.noteChartEntry.path)
	if not info then
		return
	end
	if noteChartModel.noteChartDataEntry.hash == "" then
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
		self.modifierModel:fromTable(replay.modifiers)
	end
	if event.mode == "replay" or event.mode == "result" then
		gameplayController.rhythmModel.replayModel.replay = replay
		gameplayController.rhythmModel.inputManager:setMode("internal")
		gameplayController.rhythmModel.replayModel:setMode("replay")
	elseif event.mode == "retry" then
		gameplayController.rhythmModel.inputManager:setMode("external")
		gameplayController.rhythmModel.replayModel:setMode("record")
	end

	gameplayController.noteChartModel = noteChartModel
	gameplayController.modifierModel = self.modifierModel
	gameplayController.configModel = self.configModel
	gameplayController.selectController = self

	if event.mode == "result" then
		noteChartModel:unload()
		gameplayController:play()

		local ResultController = require("sphere.controllers.ResultController")
		local resultController = ResultController:new()

		resultController.scoreSystem = gameplayController.rhythmModel.scoreEngine.scoreSystem
		resultController.noteChartModel = noteChartModel
		resultController.modifierModel = self.modifierModel
		resultController.configModel = self.configModel
		resultController.autoplay = gameplayController.rhythmModel.logicEngine.autoplay
		resultController.selectController = self

		ScreenManager:set(resultController)
	else
		return ScreenManager:set(gameplayController)
	end
end

return SelectController
