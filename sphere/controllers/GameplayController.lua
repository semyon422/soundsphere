local class = require("class")
local math_util = require("math_util")
local InputMode = require("ncdk.InputMode")

---@class sphere.GameplayController
---@operator call: sphere.GameplayController
local GameplayController = class()

function GameplayController:load()
	self.loaded = true

	local rhythmModel = self.rhythmModel
	local selectModel = self.selectModel
	local noteSkinModel = self.noteSkinModel
	local configModel = self.configModel
	local modifierModel = self.modifierModel
	local difficultyModel = self.difficultyModel
	local replayModel = self.replayModel
	local fileFinder = self.fileFinder

	local noteChart = selectModel:loadNoteChart(self:getImporterSettings())

	local state = {}
	state.timeRate = 1
	state.inputMode = InputMode()
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

	local timings = config.gameplay.timings
	if replayModel.mode == "replay" then
		timings = replayModel.replay.timings
	end
	rhythmModel.timings = timings
	replayModel.timings = timings

	rhythmModel.inputManager.observable:add(replayModel)

	rhythmModel:load()

	local scoreEngine = rhythmModel.scoreEngine

	local enps, longNoteRatio, longNoteArea = difficultyModel:getDifficulty(noteChart)
	scoreEngine.baseEnps = enps
	scoreEngine.longNoteRatio = longNoteRatio
	scoreEngine.longNoteArea = longNoteArea

	rhythmModel.timeEngine:sync(love.timer.getTime())
	rhythmModel:loadAllEngines()
	replayModel:load()

	self:updateOffsets()

	local chartItem = selectModel.noteChartItem

	fileFinder:reset()
	fileFinder:addPath(chartItem.path:match("^(.+)/.-$"))
	fileFinder:addPath(noteSkin.directoryPath)
	fileFinder:addPath("userdata/hitsounds")
	fileFinder:addPath("userdata/hitsounds/midi")

	self.resourceModel:load(chartItem.path, noteChart, function()
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

---@return table
function GameplayController:getImporterSettings()
	local config = self.configModel.configs.settings
	return {
		midiConstantVolume = config.audio.midi.constantVolume
	}
end

function GameplayController:unload()
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

---@param dt number
function GameplayController:update(dt)
	self.replayModel:update()
	self.rhythmModel:update()
end

function GameplayController:discordPlay()
	local chartItem = self.selectModel.noteChartItem
	local rhythmModel = self.rhythmModel
	local length = math.min(chartItem.length, 3600 * 24)

	local timeEngine = rhythmModel.timeEngine
	self.discordModel:setPresence({
		state = "Playing",
		details = ("%s - %s [%s]"):format(
			chartItem.artist,
			chartItem.title,
			chartItem.name
		),
		endTimestamp = math.floor(os.time() + (length - timeEngine.currentTime) / timeEngine.baseTimeRate)
	})
end

function GameplayController:discordPause()
	local chartItem = self.selectModel.noteChartItem
	self.discordModel:setPresence({
		state = "Playing (paused)",
		details = ("%s - %s [%s]"):format(
			chartItem.artist,
			chartItem.title,
			chartItem.name
		)
	})
end

---@param state string
function GameplayController:changePlayState(state)
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

---@param event table
function GameplayController:receive(event)
	self.rhythmModel:receive(event)
end

function GameplayController:retry()
	local rhythmModel = self.rhythmModel

	rhythmModel.inputManager:setMode("external")
	self.replayModel:setMode("record")

	rhythmModel:unloadAllEngines()
	rhythmModel:load()
	rhythmModel.timeEngine:sync(love.timer.getTime())
	rhythmModel:loadAllEngines()
	self.replayModel:load()
	self.resourceModel:rewind()
	self:play()
end

function GameplayController:pause()
	self.rhythmModel.pauseManager:pause()
	self:discordPause()
end

function GameplayController:play()
	self.rhythmModel.pauseManager:play()
	self:discordPlay()
end

---@param x number
---@param y number
---@param z number
---@param pitch number
---@param yaw number
function GameplayController:saveCamera(x, y, z, pitch, yaw)
	local perspective = self.configModel.configs.settings.graphics.perspective
	perspective.x = x
	perspective.y = y
	perspective.z = z
	perspective.pitch = pitch
	perspective.yaw = yaw
end

---@return boolean
function GameplayController:hasResult()
	return self.rhythmModel:hasResult() and self.replayModel.mode ~= "replay"
end

function GameplayController:saveScore()
	local rhythmModel = self.rhythmModel
	local modifierModel = self.modifierModel
	local scoreSystemEntry = rhythmModel.scoreEngine.scoreSystem.entry

	local chartItem = self.selectModel.noteChartItem

	local replayHash = self.replayModel:saveReplay()
	local scoreEntry = self.scoreModel:insertScore(
		scoreSystemEntry,
		chartItem,
		replayHash,
		modifierModel:encode()
	)

	local base = rhythmModel.scoreEngine.scoreSystem.base
	if base.hitCount / base.notesCount >= 0.5 then
		self.onlineModel.onlineScoreManager:submit(chartItem, replayHash)
	end

	rhythmModel.scoreEngine.scoreEntry = scoreEntry

	self.configModel.configs.select.scoreEntryId = scoreEntry.id
end

function GameplayController:skip()
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

function GameplayController:skipIntro()
	self.rhythmModel.timeEngine:skipIntro()
end

function GameplayController:updateOffsets()
	local rhythmModel = self.rhythmModel
	local chartItem = self.selectModel.noteChartItem
	local config = self.configModel.configs.settings

	local localOffset = chartItem.localOffset or 0
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

---@param delta number
function GameplayController:increasePlaySpeed(delta)
	local speedModel = self.speedModel
	speedModel:increase(delta)

	local gameplay = self.configModel.configs.settings.gameplay
	self.rhythmModel.graphicEngine:setVisualTimeRate(gameplay.speed)
	self.notificationModel:notify("scroll speed: " .. speedModel.format[gameplay.speedType]:format(speedModel:get()))
end

---@param delta number
function GameplayController:increaseLocalOffset(delta)
	local chartItem = self.selectModel.noteChartItem
	chartItem.localOffset = math_util.round((chartItem.localOffset or 0) + delta, delta)
	self.cacheModel.chartRepo:updateNoteChartDataEntry({
		id = chartItem.noteChartDataId,
		localOffset = chartItem.localOffset,
	})
	self.notificationModel:notify("local offset: " .. chartItem.localOffset * 1000 .. "ms")
	self:updateOffsets()
end

return GameplayController
