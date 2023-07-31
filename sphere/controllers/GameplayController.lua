local Class = require("Class")
local FileFinder = require("sphere.filesystem.FileFinder")
local math_util = require("math_util")
local InputMode = require("ncdk.InputMode")

local GameplayController = Class:new()

GameplayController.load = function(self)
	self.loaded = true

	local rhythmModel = self.rhythmModel
	local noteChartModel = self.noteChartModel
	local noteSkinModel = self.noteSkinModel
	local configModel = self.configModel
	local modifierModel = self.modifierModel
	local difficultyModel = self.difficultyModel
	local replayModel = self.replayModel

	noteChartModel:load()

	local noteChart = noteChartModel:loadNoteChart(self:getImporterSettings())

	local state = {}
	state.timeRate = 1
	state.inputMode = InputMode:new()
	state.inputMode:set(noteChart.inputMode)

	modifierModel:applyMeta(state)
	modifierModel:apply(noteChart)

	local noteSkin = noteSkinModel:getNoteSkin(noteChart.inputMode)
	noteSkin:loadData()

	local config = configModel.configs.settings

	rhythmModel:setAdjustRate(config.audio.adjustRate)
	rhythmModel:setTimeRate(modifierModel.state.timeRate)
	rhythmModel:setWindUp(modifierModel.state.windUp)
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

	rhythmModel.timings = config.gameplay.timings

	replayModel.timings = config.gameplay.timings
	rhythmModel.inputManager.observable:add(replayModel)

	rhythmModel:load()

	local scoreEngine = rhythmModel.scoreEngine

	local enps, longNoteRatio, longNoteArea = difficultyModel:getDifficulty(noteChart)
	scoreEngine.baseEnps = enps
	scoreEngine.longNoteRatio = longNoteRatio
	scoreEngine.longNoteArea = longNoteArea

	rhythmModel.timeEngine:sync({
		time = love.timer.getTime(),
		delta = 0,
	})
	rhythmModel:loadAllEngines()
	replayModel:load()

	self:updateOffsets()

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

	self.windowModel:setVsyncOnSelect(false)

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
	rhythmModel.inputManager:setMode("external")
	self.replayModel:setMode("record")
	love.mouse.setVisible(true)

	self.windowModel:setVsyncOnSelect(true)

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

	local timeEngine = rhythmModel.timeEngine
	self.discordModel:setPresence({
		state = "Playing",
		details = ("%s - %s [%s]"):format(
			noteChartDataEntry.artist,
			noteChartDataEntry.title,
			noteChartDataEntry.name
		),
		endTimestamp = math.floor(os.time() + (length - timeEngine.currentTime) / timeEngine.baseTimeRate)
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
	rhythmModel:load()
	rhythmModel.timeEngine:sync({
		time = love.timer.getTime(),
		delta = 0,
	})
	rhythmModel:loadAllEngines()
	self.replayModel:load()
	self.resourceModel:rewind()
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
	return self.rhythmModel:hasResult() and self.replayModel.mode ~= "replay"
end

GameplayController.saveScore = function(self)
	local rhythmModel = self.rhythmModel
	local noteChartModel = self.noteChartModel
	local modifierModel = self.modifierModel
	local scoreSystemEntry = rhythmModel.scoreEngine.scoreSystem.entry

	local replayHash = self.replayModel:saveReplay()
	local scoreEntry = self.scoreModel:insertScore(
		scoreSystemEntry,
		noteChartModel.noteChartDataEntry,
		replayHash,
		modifierModel:encode()
	)

	local base = rhythmModel.scoreEngine.scoreSystem.base
	if base.hitCount / base.notesCount >= 0.5 then
		self.onlineModel.onlineScoreManager:submit(noteChartModel.noteChartEntry, noteChartModel.noteChartDataEntry, replayHash)
	end

	rhythmModel.scoreEngine.scoreEntry = scoreEntry

	self.configModel.configs.select.scoreEntryId = scoreEntry.id
end

GameplayController.skip = function(self)
	local rhythmModel = self.rhythmModel
	local timeEngine = rhythmModel.timeEngine

	self:update(0)

	rhythmModel.audioEngine:unload()
	timeEngine:play()
	timeEngine.currentTime = math.huge
	self.replayModel:update()
	rhythmModel.logicEngine:update()
	rhythmModel.scoreEngine:update()
end

GameplayController.skipIntro = function(self)
	self.rhythmModel.timeEngine:skipIntro()
end

GameplayController.updateOffsets = function(self)
	local rhythmModel = self.rhythmModel
	local noteChartDataEntry = self.noteChartModel.noteChartDataEntry
	local config = self.configModel.configs.settings

	local localOffset = noteChartDataEntry.localOffset or 0
	local baseTimeRate = rhythmModel.timeEngine.baseTimeRate
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
end

GameplayController.increasePlaySpeed = function(self, delta)
	local speedModel = self.speedModel
	speedModel:increase(delta)

	local gameplay = self.configModel.configs.settings.gameplay
	self.rhythmModel.graphicEngine:setVisualTimeRate(gameplay.speed)
	self.notificationModel:notify("scroll speed: " .. speedModel.format[gameplay.speedType]:format(speedModel:get()))
end

GameplayController.increaseLocalOffset = function(self, delta)
	local entry = self.noteChartModel.noteChartDataEntry
	entry.localOffset = math_util.round((entry.localOffset or 0) + delta, delta)
	self.cacheModel.chartRepo:updateNoteChartDataEntry(entry)
	self.notificationModel:notify("local offset: " .. entry.localOffset * 1000 .. "ms")
	self:updateOffsets()
end

return GameplayController
