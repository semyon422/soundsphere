local Class						= require("aqua.util.Class")
local sound						= require("aqua.sound")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")

local GameplayController = Class:new()

GameplayController.load = function(self)
	local rhythmModel = self.game.rhythmModel
	local noteChartModel = self.game.noteChartModel
	local noteSkinModel = self.game.noteSkinModel
	local inputModel = self.game.inputModel
	local configModel = self.game.configModel
	local modifierModel = self.game.modifierModel
	local difficultyModel = self.game.difficultyModel

	noteChartModel:load()

	local noteChart = noteChartModel:loadNoteChart(self:getImporterSettings())
	modifierModel:apply("NoteChartModifier")

	self.game.modifierModel.noteChart = noteChart

	local noteChartDataEntry = noteChartModel.noteChartDataEntry
	local localOffset = noteChartDataEntry.localOffset or 0

	local config = configModel.configs.settings

	rhythmModel:setVolume(config.audio.volume)
	rhythmModel:setAudioMode(config.audio.mode)
	rhythmModel:setLongNoteShortening(config.gameplay.longNoteShortening)
	rhythmModel:setTimeToPrepare(config.gameplay.time.prepare)
	rhythmModel:setVisualTimeRate(config.gameplay.speed)
	rhythmModel:setVisualTimeRateScale(config.gameplay.scaleSpeed)
	rhythmModel:setPauseTimes(config.gameplay.time)
	rhythmModel:setInputBindings(inputModel:getInputBindings())
	rhythmModel:setNoteChart(noteChart)
	rhythmModel:setNoteSkin(noteSkinModel:getNoteSkin(noteChart.inputMode))
	rhythmModel.inputManager:setInputMode(noteChart.inputMode:getString())

	rhythmModel:load()

	local scoreEngine = rhythmModel.scoreEngine

	local enps, longNoteRatio, longNoteArea = difficultyModel:getDifficulty(noteChart)
	scoreEngine.baseEnps = enps
	scoreEngine.longNoteRatio = longNoteRatio
	scoreEngine.longNoteArea = longNoteArea

	scoreEngine.noteChartDataEntry = noteChartDataEntry

	rhythmModel.timeEngine:sync({
		time = love.timer.getTime(),
		delta = 0,
	})
	assert(self.game.modifierModel.config)
	rhythmModel:loadAllEngines()

	local baseTimeRate = rhythmModel.timeEngine:getBaseTimeRate()
	local inputOffset = config.gameplay.offset.input + localOffset
	local visualOffset = config.gameplay.offset.visual + localOffset
	if config.gameplay.offsetScale.input then
		inputOffset = inputOffset * baseTimeRate
	end
	if config.gameplay.offsetScale.visual then
		visualOffset = visualOffset * baseTimeRate
	end
	rhythmModel:setInputOffset(inputOffset)
	rhythmModel:setVisualOffset(visualOffset)

	sound.sample_gain = config.audio.sampleGain
	NoteChartResourceLoader:load(noteChartModel.noteChartEntry.path, noteChart, function()
		rhythmModel:setResourceAliases(NoteChartResourceLoader.aliases)
		self:play()
	end)

	love.mouse.setVisible(false)

	local graphics = self.game.configModel.configs.settings.graphics
	local flags = graphics.mode.flags
	if graphics.vsyncOnSelect then
		self.game.baseVsync = flags.vsync ~= 0 and flags.vsync or 1
		flags.vsync = 0
	end

	self.game.multiplayerModel:setIsPlaying(true)
end

GameplayController.getImporterSettings = function(self)
	local config = self.game.configModel.configs.settings
	return {
		midiConstantVolume = config.audio.midi.constantVolume
	}
end

GameplayController.unload = function(self)
	self.game.discordModel:setPresence({})
	self:skip()
	self:saveScore()

	local rhythmModel = self.game.rhythmModel
	rhythmModel:unloadAllEngines()
	rhythmModel:unload()
	rhythmModel.inputManager:setMode("external")
	self.game.replayModel:setMode("record")
	love.mouse.setVisible(true)

	local graphics = self.game.configModel.configs.settings.graphics
	local flags = graphics.mode.flags
	if graphics.vsyncOnSelect and flags.vsync == 0 then
		flags.vsync = self.game.baseVsync
	end

	self.game.multiplayerModel:setIsPlaying(false)
end

GameplayController.update = function(self, dt)
	self.game.rhythmModel:update(dt)
end

GameplayController.discordPlay = function(self)
	local noteChartDataEntry = self.game.noteChartModel.noteChartDataEntry
	local rhythmModel = self.game.rhythmModel
	local length = math.min(noteChartDataEntry.length, 3600 * 24)
	self.game.discordModel:setPresence({
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
	local noteChartDataEntry = self.game.noteChartModel.noteChartDataEntry
	self.game.discordModel:setPresence({
		state = "Playing (paused)",
		details = ("%s - %s [%s]"):format(
			noteChartDataEntry.artist,
			noteChartDataEntry.title,
			noteChartDataEntry.name
		)
	})
end

GameplayController.receive = function(self, event)
	local rhythmModel = self.game.rhythmModel
	rhythmModel:receive(event)

	if event.name == "playStateChange" then
		if event.state == "play" then
			self:discordPlay()
		elseif event.state == "pause" then
			self:discordPause()
		end
	end
end

GameplayController.retry = function(self)
	self.game.rhythmModel.inputManager:setMode("external")
	self.game.replayModel:setMode("record")
	self:unload()
	self:load()
end

GameplayController.pause = function(self)
	self.game.rhythmModel.pauseManager:pause()
	self:discordPause()
end

GameplayController.play = function(self)
	self.game.rhythmModel.pauseManager:play()
	self:discordPlay()
end

GameplayController.saveCamera = function(self, x, y, z, pitch, yaw)
	local perspective = self.game.configModel.configs.settings.graphics.perspective
	perspective.x = x
	perspective.y = y
	perspective.z = z
	perspective.pitch = pitch
	perspective.yaw = yaw
end

GameplayController.hasResult = function(self)
	local rhythmModel = self.game.rhythmModel
	return not rhythmModel.logicEngine.autoplay and not rhythmModel.prohibitSavingScore
end

GameplayController.saveScore = function(self)
	local rhythmModel = self.game.rhythmModel
	if rhythmModel.prohibitSavingScore then
		return
	end

	local scoreSystemEntry = rhythmModel.scoreEngine.scoreSystem.entry
	local noteChartModel = self.game.noteChartModel
	local modifierModel = self.game.modifierModel
	local replayModel = self.game.replayModel
	if
		scoreSystemEntry.accuracy > 0 and
		scoreSystemEntry.accuracy < math.huge and
		replayModel.mode ~= "replay" and
		not rhythmModel.logicEngine.autoplay
	then
		replayModel.noteChartModel = noteChartModel
		replayModel.modifierModel = modifierModel
		local replayHash = replayModel:saveReplay()
		local scoreEntry = self.game.scoreModel:insertScore(scoreSystemEntry, noteChartModel.noteChartDataEntry, replayHash, modifierModel)

		if
			rhythmModel.scoreEngine.scoreSystem.base.progress >= 1 and
			not rhythmModel.logicEngine.promode
		then
			self.game.onlineModel.onlineScoreManager:submit(noteChartModel.noteChartEntry, noteChartModel.noteChartDataEntry, replayHash)
		end

		rhythmModel.scoreEngine.scoreEntry = scoreEntry
		local config = self.game.configModel.configs.select
		config.scoreEntryId = scoreEntry.id
		self.game.selectModel:pullScore()

		return scoreEntry
	end
end

GameplayController.skip = function(self)
	local rhythmModel = self.game.rhythmModel
	local timeEngine = rhythmModel.timeEngine

	self:update(0)

	rhythmModel.audioEngine:unload()

	local base = rhythmModel.scoreEngine.scoreSystem.base
	if timeEngine.currentTime >= timeEngine.maxTime then
		base.progress = 1
	end

	if timeEngine.currentTime < timeEngine.minTime or base.hitCount == 0 then
		rhythmModel.prohibitSavingScore = true
	end

	timeEngine:resetTimeRate()
	timeEngine:play()
	timeEngine.currentTime = math.huge
	self.game.replayModel.currentTime = math.huge
	self.game.replayModel:update()
	rhythmModel.logicEngine:update()
	rhythmModel.scoreEngine:update()
	self.game.modifierModel:update()
end

return GameplayController
