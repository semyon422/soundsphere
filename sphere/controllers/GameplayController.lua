local Class						= require("aqua.util.Class")
local RhythmModel				= require("sphere.models.RhythmModel")
local TimeController			= require("sphere.controllers.TimeController")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")

local GameplayController = Class:new()

GameplayController.construct = function(self)
	self.rhythmModel = RhythmModel:new()
	self.timeController = TimeController:new()
end

GameplayController.load = function(self)
	local rhythmModel = self.rhythmModel
	local timeController = self.timeController

	local noteChartModel = self.gameController.noteChartModel
	local noteSkinModel = self.gameController.noteSkinModel
	local inputModel = self.gameController.inputModel
	local configModel = self.gameController.configModel
	local modifierModel = self.gameController.modifierModel
	local notificationModel = self.gameController.notificationModel
	local themeModel = self.gameController.themeModel
	local difficultyModel = self.gameController.difficultyModel
	local backgroundModel = self.gameController.backgroundModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("GameplayView")
	self.view = view

	noteSkinModel.configModel = configModel

	noteChartModel:load()
	noteSkinModel:load()

	view.rhythmModel = rhythmModel
	view.noteChartModel = noteChartModel
	view.configModel = configModel
	view.modifierModel = modifierModel
	view.backgroundModel = backgroundModel
	view.controller = self

	timeController.rhythmModel = rhythmModel
	timeController.configModel = configModel
	timeController.notificationModel = notificationModel

	modifierModel.rhythmModel = rhythmModel
	modifierModel.noteChartModel = noteChartModel

	rhythmModel.modifierModel = modifierModel

	local noteChart = noteChartModel:loadNoteChart(self:getImporterSettings())
	rhythmModel:setNoteChart(noteChart)
	rhythmModel.noteChart = noteChart

	local config = configModel:getConfig("settings")

	rhythmModel:setVolume("global", config.audio.volume.master)
	rhythmModel:setVolume("music", config.audio.volume.music)
	rhythmModel:setVolume("effects", config.audio.volume.effects)
	rhythmModel:setAudioMode("primary", config.audio.mode.primary)
	rhythmModel:setAudioMode("secondary", config.audio.mode.secondary)
	rhythmModel:setTimeRound(config.gameplay.needTimeRound)
	rhythmModel:setTimeToPrepare(config.gameplay.time.prepare)
	rhythmModel:setNoteOffset(config.gameplay.offset.note)
	rhythmModel:setInputOffset(config.gameplay.offset.input)
	rhythmModel:setVisualTimeRate(config.gameplay.speed)
	rhythmModel:setPauseTimes(
		config.gameplay.time.playPause,
		config.gameplay.time.pausePlay,
		config.gameplay.time.playRetry,
		config.gameplay.time.pauseRetry
	)

	rhythmModel:setInputBindings(inputModel:getInputBindings())
	rhythmModel:load()

	modifierModel:apply("NoteChartModifier")

	rhythmModel.inputManager:setInputMode(noteChart.inputMode:getString())

	local noteSkin = noteSkinModel:getNoteSkin(noteChart.inputMode)
	noteSkin:load()
	rhythmModel:setNoteSkin(noteSkin)
	view.noteSkin = noteSkin

	rhythmModel:loadAllEngines()

	local scoreEngine = rhythmModel.scoreEngine

	local enps, averageStrain, generalizedKeymode = difficultyModel:getDifficulty(noteChart)
	scoreEngine.baseEnps = enps
	scoreEngine.baseAverageStrain = averageStrain
	scoreEngine.generalizedKeymode = generalizedKeymode

	view.scoreSystem = scoreEngine.scoreSystem

	view:load()

	NoteChartResourceLoader:load(noteChartModel.noteChartEntry.path, noteChart, function()
		rhythmModel:setResourceAliases(NoteChartResourceLoader.localAliases, NoteChartResourceLoader.globalAliases)
		self:receive({
			name = "play"
		})
	end)

	rhythmModel.observable:add(view)
end

GameplayController.getImporterSettings = function(self)
	local config = self.gameController.configModel:getConfig("settings")
	return {
		midiConstantVolume = config.audio.midi.constantVolume
	}
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
		self.rhythmModel.pauseManager:play()
	elseif event.name == "pause" then
		self.rhythmModel.pauseManager:pause()
	elseif event.name == "retry" then
		self.rhythmModel.inputManager:setMode("external")
		self.rhythmModel.replayModel:setMode("record")
		self:unload()
		self:load()
	elseif event.name == "saveCamera" then
		local perspective = self.gameController.configModel:getConfig("settings").graphics.perspective
		perspective.x = event.x
		perspective.y = event.y
		perspective.z = event.z
		perspective.pitch = event.pitch
		perspective.yaw = event.yaw
	elseif event.name == "quit" then
		self:skip()
		local scoreEntry = self:saveScore()
		if scoreEntry then
			local ResultController = require("sphere.controllers.ResultController")
			local resultController = ResultController:new()

			resultController.rhythmModel = self.rhythmModel
			resultController.selectController = self.selectController
			resultController.gameController = self.gameController

			self.gameController.screenManager:set(resultController)
		else
			self.gameController.screenManager:set(self.selectController)
		end
	end
end

GameplayController.saveScore = function(self)
	local rhythmModel = self.rhythmModel
	if rhythmModel.prohibitSavingScore then
		return
	end

	local scoreSystemEntry = rhythmModel.scoreEngine.scoreSystem.entry
	local noteChartModel = self.gameController.noteChartModel
	local modifierModel = rhythmModel.modifierModel
	local replayModel = rhythmModel.replayModel
	if scoreSystemEntry.score > 0 and rhythmModel.replayModel.mode ~= "replay" and not rhythmModel.logicEngine.autoplay then
		replayModel.noteChartModel = noteChartModel
		replayModel.modifierModel = modifierModel
		replayModel.replayType = self.gameController.configModel:getConfig("settings").gameplay.replayType
		local replayHash = replayModel:saveReplay()
		local scoreEntry = self.gameController.scoreModel:insertScore(scoreSystemEntry, noteChartModel.noteChartDataEntry, replayHash, modifierModel)
		self.gameController.onlineModel:submit(noteChartModel.noteChartEntry, noteChartModel.noteChartDataEntry, replayHash)

		rhythmModel.scoreEngine.scoreEntry = scoreEntry
		local config = self.gameController.configModel:getConfig("select")
		config.scoreEntryId = scoreEntry.id
		self.gameController.selectModel:pullScore()

		return scoreEntry
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
	self:update(0)
	self.rhythmModel.replayModel:update()
	self:update(0)
end

return GameplayController
