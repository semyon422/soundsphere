local Class						= require("aqua.util.Class")
local TimeController			= require("sphere.controllers.TimeController")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")

local GameplayController = Class:new()

GameplayController.construct = function(self)
	self.timeController = TimeController:new()
end

GameplayController.load = function(self)
	local timeController = self.timeController

	local rhythmModel = self.gameController.rhythmModel
	local noteChartModel = self.gameController.noteChartModel
	local noteSkinModel = self.gameController.noteSkinModel
	local inputModel = self.gameController.inputModel
	local configModel = self.gameController.configModel
	local modifierModel = self.gameController.modifierModel
	local notificationModel = self.gameController.notificationModel
	local themeModel = self.gameController.themeModel
	local difficultyModel = self.gameController.difficultyModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("GameplayView")
	self.view = view

	noteSkinModel.configModel = configModel

	noteChartModel:load()
	noteSkinModel:load()

	view.controller = self
	view.gameController = self.gameController

	timeController.gameController = self.gameController

	local noteChart = noteChartModel:loadNoteChart(self:getImporterSettings())
	rhythmModel:setNoteChart(noteChart)
	rhythmModel.noteChart = noteChart

	local noteChartDataEntry = noteChartModel.noteChartDataEntry
	local localOffset = noteChartDataEntry.localOffset

	local config = configModel.configs.settings

	rhythmModel:setVolume("global", config.audio.volume.master)
	rhythmModel:setVolume("music", config.audio.volume.music)
	rhythmModel:setVolume("effects", config.audio.volume.effects)
	rhythmModel:setAudioMode("primary", config.audio.mode.primary)
	rhythmModel:setAudioMode("secondary", config.audio.mode.secondary)
	rhythmModel:setTimeRound(config.gameplay.needTimeRound)
	rhythmModel:setTimeToPrepare(config.gameplay.time.prepare)
	rhythmModel:setNoteOffset(config.gameplay.offset.note + localOffset)
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
	rhythmModel:setNoteSkin(noteSkin)

	local scoreEngine = rhythmModel.scoreEngine

	local enps, averageStrain, generalizedKeymode = difficultyModel:getDifficulty(noteChart)
	scoreEngine.baseEnps = enps
	scoreEngine.baseAverageStrain = averageStrain
	scoreEngine.generalizedKeymode = generalizedKeymode

	scoreEngine.noteChartDataEntry = noteChartDataEntry

	rhythmModel:loadAllEngines()

	view:load()

	NoteChartResourceLoader:load(noteChartModel.noteChartEntry.path, noteChart, function()
		rhythmModel:setResourceAliases(NoteChartResourceLoader.localAliases, NoteChartResourceLoader.globalAliases)
		self:receive({
			name = "play"
		})
	end)

	rhythmModel.observable:add(view)
	love.mouse.setVisible(false)
end

GameplayController.getImporterSettings = function(self)
	local config = self.gameController.configModel.configs.settings
	return {
		midiConstantVolume = config.audio.midi.constantVolume
	}
end

GameplayController.unload = function(self)
	local rhythmModel = self.gameController.rhythmModel
	rhythmModel:unloadAllEngines()
	rhythmModel:unload()
	self.view:unload()
	rhythmModel.observable:remove(self.view)
	rhythmModel.inputManager:setMode("external")
	rhythmModel.replayModel:setMode("record")
	love.mouse.setVisible(true)
end

GameplayController.update = function(self, dt)
	self.gameController.rhythmModel:update(dt)
	self.view:update(dt)
end

GameplayController.draw = function(self)
	self.view:draw()
end

GameplayController.receive = function(self, event)
	self.timeController:receive(event)
	local rhythmModel = self.gameController.rhythmModel
	rhythmModel:receive(event)
	self.view:receive(event)

	if event.name == "play" then
		rhythmModel.pauseManager:play()
	elseif event.name == "pause" then
		rhythmModel.pauseManager:pause()
	elseif event.name == "retry" then
		rhythmModel.inputManager:setMode("external")
		rhythmModel.replayModel:setMode("record")
		self:unload()
		self:load()
	elseif event.name == "saveCamera" then
		local perspective = self.gameController.configModel.configs.settings.graphics.perspective
		perspective.x = event.x
		perspective.y = event.y
		perspective.z = event.z
		perspective.pitch = event.pitch
		perspective.yaw = event.yaw
	elseif event.name == "quit" then
		self:skip()
		self:saveScore()
		if not rhythmModel.logicEngine.autoplay then
			local ResultController = require("sphere.controllers.ResultController")
			local resultController = ResultController:new()

			resultController.selectController = self.selectController
			resultController.gameController = self.gameController

			self.gameController.screenManager:set(resultController)
		else
			self.gameController.screenManager:set(self.selectController)
		end
	end
end

GameplayController.saveScore = function(self)
	local rhythmModel = self.gameController.rhythmModel
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
		replayModel.replayType = self.gameController.configModel.configs.settings.gameplay.replayType
		local replayHash = replayModel:saveReplay()
		local scoreEntry = self.gameController.scoreModel:insertScore(scoreSystemEntry, noteChartModel.noteChartDataEntry, replayHash, modifierModel)
		self.gameController.onlineModel:submit(noteChartModel.noteChartEntry, noteChartModel.noteChartDataEntry, replayHash)

		rhythmModel.scoreEngine.scoreEntry = scoreEntry
		local config = self.gameController.configModel.configs.select
		config.scoreEntryId = scoreEntry.id
		self.gameController.selectModel:pullScore()

		return scoreEntry
	end
end

GameplayController.skip = function(self)
	local rhythmModel = self.gameController.rhythmModel
	local timeEngine = rhythmModel.timeEngine

	rhythmModel.audioEngine:unload()
	rhythmModel.logicEngine.observable:remove(rhythmModel.audioEngine)

	local time = math.huge
	timeEngine:setTimeRate(timeEngine:getBaseTimeRate())
	timeEngine.currentTime = time
	timeEngine.exactCurrentTime = time
	timeEngine:sendState()
	self:update(0)
	rhythmModel.replayModel:update()
	self:update(0)
end

return GameplayController
