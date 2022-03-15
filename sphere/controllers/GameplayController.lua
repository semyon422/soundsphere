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

	view.controller = self
	view.gameController = self.gameController

	timeController.gameController = self.gameController

	local noteChart = noteChartModel:loadNoteChart(self:getImporterSettings())
	rhythmModel:setNoteChart(noteChart)
	rhythmModel.noteChart = noteChart
	rhythmModel.prohibitSavingScore = false

	local noteChartDataEntry = noteChartModel.noteChartDataEntry
	local localOffset = noteChartDataEntry.localOffset

	local config = configModel.configs.settings

	rhythmModel:setVolume("global", config.audio.volume.master)
	rhythmModel:setVolume("music", config.audio.volume.music)
	rhythmModel:setVolume("effects", config.audio.volume.effects)
	rhythmModel:setAudioMode("primary", config.audio.mode.primary)
	rhythmModel:setAudioMode("secondary", config.audio.mode.secondary)
	rhythmModel:setLongNoteShortening(config.gameplay.longNoteShortening)
	rhythmModel:setTimeToPrepare(config.gameplay.time.prepare)
	rhythmModel:setInputOffset(config.gameplay.offset.input + localOffset)
	rhythmModel:setVisualOffset(config.gameplay.offset.visual + localOffset)
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
		rhythmModel.timeEngine:sync({
			time = love.timer.getTime(),
			delta = 0,
		})
		self:receive({
			name = "play"
		})
	end)

	rhythmModel.observable:add(view)
	love.mouse.setVisible(false)
	self.drawing = true
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
	self.gameController:resetGameplayConfigs()
	love.mouse.setVisible(true)
end

GameplayController.update = function(self, dt)
	self.gameController.rhythmModel:update(dt)
	self.view:update(dt)
end

GameplayController.draw = function(self)
	if self.drawing then
		self.view:draw()
	end
end

GameplayController.discordPlay = function(self)
	local noteChartDataEntry = self.gameController.noteChartModel.noteChartDataEntry
	local rhythmModel = self.gameController.rhythmModel
	local length = math.min(noteChartDataEntry.length, 3600 * 24)
	self.gameController.discordModel:setPresence({
		state = "Playing",
		details = ("%s - %s [%s]"):format(
			noteChartDataEntry.artist,
			noteChartDataEntry.title,
			noteChartDataEntry.name
		),
		endTimestamp = math.floor(os.time() + (length - rhythmModel.timeEngine.currentTime) / rhythmModel.timeEngine:getBaseTimeRate())
	})
end

GameplayController.discordPause = function(self)
	local noteChartDataEntry = self.gameController.noteChartModel.noteChartDataEntry
	self.gameController.discordModel:setPresence({
		state = "Playing (paused)",
		details = ("%s - %s [%s]"):format(
			noteChartDataEntry.artist,
			noteChartDataEntry.title,
			noteChartDataEntry.name
		)
	})
end

GameplayController.receive = function(self, event)
	self.timeController:receive(event)
	local rhythmModel = self.gameController.rhythmModel
	rhythmModel:receive(event)
	self.view:receive(event)

	if event.name == "play" then
		rhythmModel.pauseManager:play()
		self:discordPlay()
	elseif event.name == "pause" then
		rhythmModel.pauseManager:pause()
		self:discordPause()
	elseif event.name == "retry" then
		rhythmModel.inputManager:setMode("external")
		rhythmModel.replayModel:setMode("record")
		self:unload()
		self:load()
	elseif event.name == "playStateChange" then
		if event.state == "play" then
			self:discordPlay()
		elseif event.state == "pause" then
			self:discordPause()
		end
	elseif event.name == "saveCamera" then
		local perspective = self.gameController.configModel.configs.settings.graphics.perspective
		perspective.x = event.x
		perspective.y = event.y
		perspective.z = event.z
		perspective.pitch = event.pitch
		perspective.yaw = event.yaw
	elseif event.name == "quit" then
		self.drawing = false
		self.gameController.discordModel:setPresence({})
		self:skip()
		self:saveScore()
		if not rhythmModel.logicEngine.autoplay and not rhythmModel.prohibitSavingScore then
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
	if
		scoreSystemEntry.score > 0 and
		rhythmModel.replayModel.mode ~= "replay" and
		not rhythmModel.logicEngine.autoplay
	then
		replayModel.noteChartModel = noteChartModel
		replayModel.modifierModel = modifierModel
		replayModel.replayType = self.gameController.configModel.configs.settings.gameplay.replayType
		local replayHash = replayModel:saveReplay()
		local scoreEntry = self.gameController.scoreModel:insertScore(scoreSystemEntry, noteChartModel.noteChartDataEntry, replayHash, modifierModel)

		if
			rhythmModel.scoreEngine.scoreSystem.base.progress >= 1 and
			not rhythmModel.logicEngine.promode
		then
			self.gameController.onlineModel.onlineScoreManager:submit(noteChartModel.noteChartEntry, noteChartModel.noteChartDataEntry, replayHash)
		end

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

	self:update(0)

	rhythmModel.audioEngine:unload()
	rhythmModel.logicEngine.observable:remove(rhythmModel.audioEngine)

	if timeEngine.currentTime >= timeEngine.maxTime then
		rhythmModel.scoreEngine.scoreSystem.base.progress = 1
	end

	if timeEngine.currentTime < timeEngine.minTime then
		rhythmModel.prohibitSavingScore = true
	end

	timeEngine:resetTimeRate()
	timeEngine:play()
	timeEngine.currentTime = math.huge
	rhythmModel.replayModel.currentTime = math.huge
	rhythmModel.replayModel:update()
	rhythmModel.logicEngine:update()
	rhythmModel.scoreEngine:update()
	rhythmModel.modifierModel:update()
end

return GameplayController
