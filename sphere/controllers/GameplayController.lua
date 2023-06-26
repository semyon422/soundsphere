local Class						= require("Class")
local FileFinder	= require("sphere.filesystem.FileFinder")

local GameplayController = Class:new()

GameplayController.load = function(self)
	self.loaded = true

	local rhythmModel = self.rhythmModel
	local noteChartModel = self.noteChartModel
	local noteSkinModel = self.noteSkinModel
	local configModel = self.configModel
	local modifierModel = self.modifierModel
	local difficultyModel = self.difficultyModel

	noteChartModel:load()

	local noteChart = noteChartModel:loadNoteChart(self:getImporterSettings())
	modifierModel:apply("NoteChartModifier")

	self.modifierModel.noteChart = noteChart

	local noteSkin = noteSkinModel:getNoteSkin(noteChart.inputMode)
	noteSkin:loadData()

	local config = configModel.configs.settings

	rhythmModel:setVolume(config.audio.volume)
	rhythmModel:setAudioMode(config.audio.mode)
	rhythmModel:setLongNoteShortening(config.gameplay.longNoteShortening)
	rhythmModel:setTimeToPrepare(config.gameplay.time.prepare)
	rhythmModel:setVisualTimeRate(config.gameplay.speed)
	rhythmModel:setVisualTimeRateScale(config.gameplay.scaleSpeed)
	rhythmModel:setPauseTimes(config.gameplay.time)
	rhythmModel:setNoteChart(noteChart)
	rhythmModel:setDrawRange(noteSkin.range)
	rhythmModel.inputManager:setInputMode(tostring(noteChart.inputMode))

	rhythmModel:load()

	local scoreEngine = rhythmModel.scoreEngine

	local enps, longNoteRatio, longNoteArea = difficultyModel:getDifficulty(noteChart)
	scoreEngine.baseEnps = enps
	scoreEngine.longNoteRatio = longNoteRatio
	scoreEngine.longNoteArea = longNoteArea

	scoreEngine.noteChartDataEntry = noteChartModel.noteChartDataEntry

	rhythmModel.timeEngine:sync({
		time = love.timer.getTime(),
		delta = 0,
	})
	assert(self.modifierModel.config)
	rhythmModel:loadAllEngines()
	self.replayModel:load()

	self.timeController:updateOffsets()

	FileFinder:reset()
	FileFinder:addPath(noteChartModel.noteChartEntry.path:match("^(.+)/.-$"))
	FileFinder:addPath(noteSkin.directoryPath)
	FileFinder:addPath("userdata/hitsounds")
	FileFinder:addPath("userdata/hitsounds/midi")

	self.resourceModel:load(noteChartModel.noteChartEntry.path, noteChart, function()
		if not self.loaded then
			return
		end
		self:play()
	end)

	love.mouse.setVisible(false)

	local graphics = self.configModel.configs.settings.graphics
	local flags = graphics.mode.flags
	if graphics.vsyncOnSelect then
		self.windowModel.baseVsync = flags.vsync ~= 0 and flags.vsync or 1
		flags.vsync = 0
	end

	self.multiplayerModel:setIsPlaying(true)

	self.previewModel:stop()
end

GameplayController.getImporterSettings = function(self)
	local config = self.configModel.configs.settings
	return {
		midiConstantVolume = config.audio.midi.constantVolume
	}
end

GameplayController.unload = function(self)
	self.loaded = false

	self.discordModel:setPresence({})
	self:skip()

	if self:hasResult() then
		self:saveScore()
	end

	local rhythmModel = self.rhythmModel
	rhythmModel:unloadAllEngines()
	rhythmModel:unload()
	rhythmModel.inputManager:setMode("external")
	self.replayModel:setMode("record")
	love.mouse.setVisible(true)

	local graphics = self.configModel.configs.settings.graphics
	local flags = graphics.mode.flags
	if graphics.vsyncOnSelect and flags.vsync == 0 then
		flags.vsync = self.windowModel.baseVsync
	end

	self.multiplayerModel:setIsPlaying(false)
end

GameplayController.update = function(self, dt)
	self.replayModel:update()
	self.rhythmModel:update(dt)
end

GameplayController.discordPlay = function(self)
	local noteChartDataEntry = self.noteChartModel.noteChartDataEntry
	local rhythmModel = self.rhythmModel
	local length = math.min(noteChartDataEntry.length, 3600 * 24)
	self.discordModel:setPresence({
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
	local noteChartDataEntry = self.noteChartModel.noteChartDataEntry
	self.discordModel:setPresence({
		state = "Playing (paused)",
		details = ("%s - %s [%s]"):format(
			noteChartDataEntry.artist,
			noteChartDataEntry.title,
			noteChartDataEntry.name
		)
	})
end

GameplayController.changePlayState = function(self, state)
	if self.multiplayerModel.room then
		return
	end

	if state == "play" then
		self:discordPlay()
	elseif state == "pause" then
		self:discordPause()
	end

	self.rhythmModel.pauseManager:changePlayState(state)
end

GameplayController.receive = function(self, event)
	self.rhythmModel:receive(event)
end

GameplayController.retry = function(self)
	local rhythmModel = self.rhythmModel

	rhythmModel.inputManager:setMode("external")
	self.replayModel:setMode("record")

	rhythmModel:unloadAllEngines()
	rhythmModel:unload()
	rhythmModel:load()
	rhythmModel.timeEngine:sync({
		time = love.timer.getTime(),
		delta = 0,
	})
	rhythmModel:loadAllEngines()
	self.replayModel:load()
	self:play()
end

GameplayController.pause = function(self)
	self.rhythmModel.pauseManager:pause()
	self:discordPause()
end

GameplayController.play = function(self)
	self.rhythmModel.pauseManager:play()
	self:discordPlay()
end

GameplayController.saveCamera = function(self, x, y, z, pitch, yaw)
	local perspective = self.configModel.configs.settings.graphics.perspective
	perspective.x = x
	perspective.y = y
	perspective.z = z
	perspective.pitch = pitch
	perspective.yaw = yaw
end

GameplayController.hasResult = function(self)
	local rhythmModel = self.rhythmModel
	local replayModel = self.replayModel
	local timeEngine = rhythmModel.timeEngine
	local base = rhythmModel.scoreEngine.scoreSystem.base
	local entry = rhythmModel.scoreEngine.scoreSystem.entry

	return
		not rhythmModel.prohibitSavingScore and
		not rhythmModel.logicEngine.autoplay and
		not rhythmModel.logicEngine.promode and
		timeEngine.currentTime >= timeEngine.minTime and
		base.hitCount > 0 and
		entry.accuracy > 0 and
		entry.accuracy < math.huge and
		replayModel.mode ~= "replay"
end

GameplayController.saveScore = function(self)
	local rhythmModel = self.rhythmModel
	local noteChartModel = self.noteChartModel
	local modifierModel = self.modifierModel
	local replayModel = self.replayModel
	local scoreSystemEntry = rhythmModel.scoreEngine.scoreSystem.entry

	replayModel.noteChartModel = noteChartModel
	replayModel.modifierModel = modifierModel
	local replayHash = replayModel:saveReplay()
	local scoreEntry = self.scoreModel:insertScore(scoreSystemEntry, noteChartModel.noteChartDataEntry, replayHash, modifierModel)

	local base = rhythmModel.scoreEngine.scoreSystem.base
	if base.hitCount / base.noteCount >= 0.5 then
		self.onlineModel.onlineScoreManager:submit(noteChartModel.noteChartEntry, noteChartModel.noteChartDataEntry, replayHash)
	end

	rhythmModel.scoreEngine.scoreEntry = scoreEntry
	local config = self.configModel.configs.select
	config.scoreEntryId = scoreEntry.id
	self.selectModel:pullScore()
end

GameplayController.skip = function(self)
	local rhythmModel = self.rhythmModel
	local timeEngine = rhythmModel.timeEngine

	self:update(0)

	rhythmModel.audioEngine:unload()

	local base = rhythmModel.scoreEngine.scoreSystem.base
	if timeEngine.currentTime < timeEngine.minTime or base.hitCount == 0 then
		rhythmModel.prohibitSavingScore = true
	end

	timeEngine:resetTimeRate()
	timeEngine:play()
	timeEngine.currentTime = math.huge
	self.replayModel.currentTime = math.huge
	self.replayModel:update()
	rhythmModel.logicEngine:update()
	rhythmModel.scoreEngine:update()
	self.modifierModel:update()
end

return GameplayController
