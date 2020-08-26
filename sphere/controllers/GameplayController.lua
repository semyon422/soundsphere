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
	local modifierModel = self.modifierModel

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

	rhythmModel.modifierModel = modifierModel

	local noteChart = noteChartModel:loadNoteChart()
	rhythmModel:setNoteChart(noteChart)
	rhythmModel.noteChart = noteChart

	rhythmModel:setVolume("global", configModel:get("volume.global"))
	rhythmModel:setVolume("music", configModel:get("volume.music"))
	rhythmModel:setVolume("effects", configModel:get("volume.effects"))
	rhythmModel:setAudioMode("primary", configModel:get("audio.primaryAudioMode"))
	rhythmModel:setAudioMode("secondary", configModel:get("audio.secondaryAudioMode"))

	rhythmModel:setInputBindings(inputModel:getInputBindings())
	rhythmModel:load()

	modifierModel:apply("NoteChartModifier")

	rhythmModel.inputManager:setInputMode(noteChart.inputMode:getString())

	local noteSkin = noteSkinModel:getNoteSkin(noteChart.inputMode)
	noteSkin.visualTimeRate = configModel:get("speed")
	noteSkin.targetVisualTimeRate = configModel:get("speed")
	noteSkin:load()
	rhythmModel:setNoteSkin(noteSkin)
	view.noteSkin = noteSkin

	rhythmModel:loadAllEngines()

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
	self.rhythmModel:unloadAllEngines()
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
		self:skip()
		self:saveScore()
		local ResultController = require("sphere.controllers.ResultController")
		local resultController = ResultController:new()

		resultController.scoreSystem = self.rhythmModel.scoreEngine.scoreSystem
		resultController.noteChartModel = self.noteChartModel
		resultController.modifierModel = self.modifierModel
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
	local replayModel = rhythmModel.replayModel
	if scoreSystem.scoreTable.score > 0 and rhythmModel.replayModel.mode ~= "replay" and not rhythmModel.logicEngine.autoplay then
		replayModel.noteChartModel = noteChartModel
		replayModel.modifierModel = modifierModel
		replayModel.replayType = self.configModel:get("replay.type")
		local replayHash = replayModel:saveReplay()
		ScoreManager:insertScore(scoreSystem.scoreTable, noteChartModel.noteChartDataEntry, replayHash, modifierModel)
	end
end

GameplayController.skip = function(self)
	local rhythmModel = self.rhythmModel
	local timeEngine = rhythmModel.timeEngine

	rhythmModel.audioEngine:unload()
	rhythmModel.logicEngine.observable:remove(rhythmModel.audioEngine)

	local time = math.huge
	timeEngine:setTimeRate(timeEngine:getBaseTimeRate())
	timeEngine.currentTime = time
	timeEngine.exactCurrentTime = time
	timeEngine:sendState()
	self:update()
	self.rhythmModel.replayModel:update()
	self:update()
end

return GameplayController
