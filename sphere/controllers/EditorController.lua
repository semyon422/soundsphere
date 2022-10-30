local Class						= require("Class")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")
local FileFinder	= require("sphere.filesystem.FileFinder")

local EditorController = Class:new()

EditorController.load = function(self)
	self.loaded = true

	local rhythmModel = self.game.rhythmModel
	local noteChartModel = self.game.noteChartModel
	local noteSkinModel = self.game.noteSkinModel
	local configModel = self.game.configModel
	local modifierModel = self.game.modifierModel
	local difficultyModel = self.game.difficultyModel

	noteChartModel:load()

	local noteChart = noteChartModel:loadNoteChart(self:getImporterSettings())
	modifierModel:apply("NoteChartModifier")

	self.game.modifierModel.noteChart = noteChart

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
	rhythmModel:setNoteSkin(noteSkin)
	rhythmModel.inputManager:setInputMode(noteChart.inputMode:getString())

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
	assert(self.game.modifierModel.config)
	rhythmModel:loadAllEngines()

	self.game.timeController:updateOffsets()

	FileFinder:reset()
	FileFinder:addPath(noteChartModel.noteChartEntry.path:match("^(.+)/.-$"))
	FileFinder:addPath(noteSkin.directoryPath)
	FileFinder:addPath("userdata/hitsounds")
	FileFinder:addPath("userdata/hitsounds/midi")

	NoteChartResourceLoader.game = self.game
	NoteChartResourceLoader:load(noteChartModel.noteChartEntry.path, noteChart, function()
		if not self.loaded then
			return
		end
	end)

	local graphics = self.game.configModel.configs.settings.graphics
	local flags = graphics.mode.flags
	if graphics.vsyncOnSelect then
		self.game.baseVsync = flags.vsync ~= 0 and flags.vsync or 1
		flags.vsync = 0
	end

	self.game.previewModel:stop()
end

EditorController.getImporterSettings = function(self)
	local config = self.game.configModel.configs.settings
	return {
		midiConstantVolume = config.audio.midi.constantVolume
	}
end

EditorController.unload = function(self)
	self.loaded = false

	local rhythmModel = self.game.rhythmModel
	rhythmModel:unloadAllEngines()
	rhythmModel:unload()
	rhythmModel.inputManager:setMode("external")
	self.game.replayModel:setMode("record")

	local graphics = self.game.configModel.configs.settings.graphics
	local flags = graphics.mode.flags
	if graphics.vsyncOnSelect and flags.vsync == 0 then
		flags.vsync = self.game.baseVsync
	end
end

EditorController.update = function(self, dt)
	self.game.rhythmModel:update(dt)
end

EditorController.receive = function(self, event)
	self.game.rhythmModel:receive(event)
end

EditorController.pause = function(self)
	self.game.rhythmModel.pauseManager:pause()
end

EditorController.play = function(self)
	self.game.rhythmModel.pauseManager:play()
end

return EditorController
