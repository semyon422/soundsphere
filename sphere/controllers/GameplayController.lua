local Class						= require("aqua.util.Class")
local ScreenManager				= require("sphere.screen.ScreenManager")
local RhythmModel				= require("sphere.models.RhythmModel")
local NoteChartModel			= require("sphere.models.NoteChartModel")
local NoteSkinModel				= require("sphere.models.NoteSkinModel")
local InputModel				= require("sphere.models.InputModel")
local GameplayView				= require("sphere.views.GameplayView")
local TimeController			= require("sphere.controllers.TimeController")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")
local ScoreManager				= require("sphere.database.ScoreManager")

local GameplayController = Class:new()

GameplayController.construct = function(self)
	self.noteChartModel = NoteChartModel:new()
	self.noteSkinModel = NoteSkinModel:new()
	self.rhythmModel = RhythmModel:new()
	self.inputModel = InputModel:new()
	self.view = GameplayView:new()
	self.timeController = TimeController:new()
end

GameplayController.load = function(self)
	local noteChartModel = self.noteChartModel
	local noteSkinModel = self.noteSkinModel
	local rhythmModel = self.rhythmModel
	local inputModel = self.inputModel
	local configModel = self.configModel
	local view = self.view
	local timeController = self.timeController

	noteSkinModel.configModel = configModel

	noteChartModel:load()
	noteSkinModel:load()
	inputModel:load()

	view.rhythmModel = rhythmModel
	view.noteChartModel = noteChartModel
	view.configModel = configModel
	view.controller = self

	timeController.rhythmModel = rhythmModel
	timeController.configModel = configModel

	local noteChart = noteChartModel:loadNoteChart()
	rhythmModel:setNoteChart(noteChart)
	rhythmModel.noteChart = noteChart

	rhythmModel:setVolume("global", configModel:get("volume.global"))
	rhythmModel:setVolume("music", configModel:get("volume.music"))
	rhythmModel:setVolume("effects", configModel:get("volume.effects"))
	rhythmModel:setAudioMode("primary", configModel:get("audio.primaryAudioMode"))
	rhythmModel:setAudioMode("secondary", configModel:get("audio.secondaryAudioMode"))

	rhythmModel:setInputBindings(inputModel:getInputBindings())

	-- rhythmModel:load()

	local modifierModel = rhythmModel.modifierModel

	modifierModel:load()

	modifierModel:apply("NoteChartModifier")

	rhythmModel.inputManager:setInputMode(noteChart.inputMode:getString())

	local noteSkin = noteSkinModel:getNoteSkin(noteChart.inputMode)
	noteSkin.visualTimeRate = configModel:get("speed")
	noteSkin.targetVisualTimeRate = configModel:get("speed")
	noteSkin:load()
	rhythmModel:setNoteSkin(noteSkin)
	view.noteSkin = noteSkin

	rhythmModel.timeEngine:load()
	modifierModel:apply("TimeEngineModifier")

	rhythmModel.scoreEngine:load()
	modifierModel:apply("ScoreEngineModifier")

	rhythmModel.audioEngine:load()
	modifierModel:apply("AudioEngineModifier")

	modifierModel:apply("LogicEngineModifier")
	modifierModel:apply("GraphicEngineModifier")

	rhythmModel.logicEngine:load()
	rhythmModel.graphicEngine:load()
	rhythmModel.replayModel:load()

	view.scoreSystem = rhythmModel.scoreEngine.scoreSystem

	view:load()

	NoteChartResourceLoader:load(noteChartModel.noteChartEntry.path, noteChart, function()
		rhythmModel:setResourceAliases(NoteChartResourceLoader.localAliases, NoteChartResourceLoader.globalAliases)
		self:receive({
			name = "play"
		})
	end)

	rhythmModel.observable:add(view)
end

GameplayController.unload = function(self)
	self.rhythmModel:unload()
	self.view:unload()
	self.rhythmModel.observable:remove(self.view)
end

GameplayController.update = function(self, dt)
	self.rhythmModel:update(dt)
	self.view:update(dt)
end

GameplayController.draw = function(self)
	self.view:draw()
end

GameplayController.receive = function(self, event)
	self.timeController:receive(event)
	self.rhythmModel:receive(event)
	self.view:receive(event)

	if event.name == "play" then
		self.rhythmModel.timeEngine:setTimeRate(self.rhythmModel.timeEngine:getBaseTimeRate())
	elseif event.name == "pause" then
		self.rhythmModel.timeEngine:setTimeRate(0)
	elseif event.name == "restart" then
		self.rhythmModel.inputManager:setMode("external")
		self.rhythmModel.replayModel:setMode("record")
		self:unload()
		self:load()
	elseif event.name == "quit" then
		self:saveScore()
		local ResultController = require("sphere.controllers.ResultController")
		local resultController = ResultController:new()

		resultController.scoreSystem = self.rhythmModel.scoreEngine.scoreSystem
		resultController.noteChartModel = self.noteChartModel
		resultController.autoplay = self.rhythmModel.logicEngine.autoplay
		resultController.configModel = self.configModel

		ScreenManager:set(resultController)
	end
end

GameplayController.saveScore = function(self)
	local scoreSystem = self.rhythmModel.scoreEngine.scoreSystem
	local noteChartModel = self.noteChartModel
	local rhythmModel = self.rhythmModel
	local modifierModel = rhythmModel.modifierModel
	if scoreSystem.scoreTable.score > 0 and rhythmModel.replayModel.mode ~= "replay" and not rhythmModel.logicEngine.autoplay then
		local replayHash = rhythmModel.replayModel:saveReplay(noteChartModel.noteChartDataEntry, modifierModel)
		ScoreManager:insertScore(scoreSystem.scoreTable, noteChartModel.noteChartDataEntry, replayHash, modifierModel)
	end
end

return GameplayController
