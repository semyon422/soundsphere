local class = require("class")
local valid = require("valid")
local math_util = require("math_util")
local table_util = require("table_util")
local sql_util = require("rdb.sql_util")
local InputMode = require("ncdk.InputMode")
local TempoRange = require("notechart.TempoRange")
local ModifierModel = require("sphere.models.ModifierModel")
local Note = require("ncdk2.notes.Note")
local Chartplay = require("sea.chart.Chartplay")
local Chartdiff = require("sea.chart.Chartdiff")
local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")
local Subtimings = require("sea.chart.Subtimings")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")

---@class sphere.GameplayController
---@operator call: sphere.GameplayController
local GameplayController = class()

---@param rhythmModel sphere.RhythmModel
---@param selectModel sphere.SelectModel
---@param noteSkinModel sphere.NoteSkinModel
---@param configModel sphere.ConfigModel
---@param difficultyModel sphere.DifficultyModel
---@param replayModel sphere.ReplayModel
---@param multiplayerModel sphere.MultiplayerModel
---@param discordModel sphere.DiscordModel
---@param onlineModel sphere.OnlineModel
---@param resourceModel sphere.ResourceModel
---@param windowModel sphere.WindowModel
---@param speedModel sphere.SpeedModel
---@param cacheModel sphere.CacheModel
---@param fileFinder sphere.FileFinder
---@param replayBase sea.ReplayBase
---@param computeContext sea.ComputeContext
---@param pauseModel sphere.PauseModel
---@param offsetModel sphere.OffsetModel
---@param previewModel sphere.PreviewModel
---@param notificationModel sphere.NotificationModel
---@param seaClient sphere.SeaClient
function GameplayController:new(
	rhythmModel,
	selectModel,
	noteSkinModel,
	configModel,
	difficultyModel,
	replayModel,
	multiplayerModel,
	discordModel,
	onlineModel,
	resourceModel,
	windowModel,
	speedModel,
	cacheModel,
	fileFinder,
	replayBase,
	computeContext,
	pauseModel,
	offsetModel,
	previewModel,
	notificationModel,
	seaClient
)
	self.rhythmModel = rhythmModel
	self.selectModel = selectModel
	self.noteSkinModel = noteSkinModel
	self.configModel = configModel
	self.difficultyModel = difficultyModel
	self.replayModel = replayModel
	self.multiplayerModel = multiplayerModel
	self.discordModel = discordModel
	self.onlineModel = onlineModel
	self.resourceModel = resourceModel
	self.windowModel = windowModel
	self.speedModel = speedModel
	self.cacheModel = cacheModel
	self.fileFinder = fileFinder
	self.replayBase = replayBase
	self.computeContext = computeContext
	self.pauseModel = pauseModel
	self.offsetModel = offsetModel
	self.previewModel = previewModel
	self.notificationModel = notificationModel
	self.seaClient = seaClient
end

function GameplayController:load()
	self.loaded = true

	local rhythmModel = self.rhythmModel
	local selectModel = self.selectModel
	local noteSkinModel = self.noteSkinModel
	local configModel = self.configModel
	local cacheModel = self.cacheModel
	local replayModel = self.replayModel
	local pauseModel = self.pauseModel
	local fileFinder = self.fileFinder
	local replayBase = self.replayBase
	local computeContext = self.computeContext

	if replayModel.mode == "replay" then
		replayBase = rhythmModel.replayBase
	end

	local chartview = self.selectModel.chartview
	local config = configModel.configs.settings
	local judgement = configModel.configs.select.judgements

	local data = assert(love.filesystem.read(chartview.location_path))
	local chart, chartmeta = computeContext:fromFileData(chartview.chartfile_name, data, chartview.index)
	local chartdiff, state = computeContext:computeChartdiff(replayBase)

	computeContext:applyTempo(config.gameplay.tempoFactor, config.gameplay.primaryTempo)
	if config.gameplay.autoKeySound then
		computeContext:applyAutoKeysound()
	end
	if config.gameplay.swapVelocityType then
		computeContext:swapVelocityType()
	end

	local noteSkin = noteSkinModel:loadNoteSkin(tostring(chart.inputMode))
	noteSkin:loadData()

	rhythmModel.graphicEngine.eventBasedRender = config.gameplay.eventBasedRender
	rhythmModel:setAdjustRate(config.audio.adjustRate)
	rhythmModel:setVolume(config.audio.volume)
	rhythmModel:setAudioMode(config.audio.mode)

	rhythmModel:setScoring(judgement, config.gameplay.ratingHitTimingWindow)
	rhythmModel:setLongNoteShortening(config.gameplay.longNoteShortening)
	rhythmModel:setTimeToPrepare(config.gameplay.time.prepare)
	rhythmModel:setVisualTimeRate(config.gameplay.speed)
	rhythmModel:setVisualTimeRateScale(config.gameplay.scaleSpeed)

	rhythmModel:setNoteChart(chart, chartmeta, chartdiff)
	rhythmModel:setPlayTime(chartdiff.start_time, chartdiff.duration)
	rhythmModel:setDrawRange(noteSkin.range)
	rhythmModel.inputManager:setInputMode(tostring(chart.inputMode))

	self:actualizeReplayBase()

	rhythmModel:setWindUp(state.windUp)
	rhythmModel:setReplayBase(replayBase)

	rhythmModel.inputManager.observable:add(replayModel)
	rhythmModel:load()

	rhythmModel.timeEngine:sync(love.timer.getTime())
	rhythmModel:loadAllEngines()
	replayModel:load()
	pauseModel:load()

	self:updateOffsets()

	fileFinder:reset()

	if config.gameplay.skin_resources_top_priority then
		fileFinder:addPath(noteSkin.directoryPath)
		fileFinder:addPath(chartview.location_dir)
	else
		fileFinder:addPath(chartview.location_dir)
		fileFinder:addPath(noteSkin.directoryPath)
	end
	fileFinder:addPath("userdata/hitsounds")
	fileFinder:addPath("userdata/hitsounds/midi")

	self.resourceModel:load(chart, function()
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

---@param timings sea.Timings
function GameplayController:setReplayBaseTimings(timings)
	local replayBase = self.replayBase
	local settings = self.configModel.configs.settings

	local subtimings_config = settings.subtimings[timings.name]
	local name = subtimings_config[1]
	local value = subtimings_config[name]
	local subtimings = Subtimings(name, value)

	replayBase.timings = timings
	replayBase.subtimings = subtimings
	replayBase.timing_values = assert(TimingValuesFactory:get(timings, subtimings))
end

function GameplayController:actualizeReplayBaseTimings()
	local chartmeta = self.computeContext.chartmeta
	local settings = self.configModel.configs.settings

	local timings = chartmeta.timings
	timings = timings or Timings(unpack(settings.format_timings[chartmeta.format]))
	self:setReplayBaseTimings(timings)
end

function GameplayController:actualizeReplayBase()
	local config = self.configModel.configs.settings.replay_base

	if config.auto_timings then
		self:actualizeReplayBaseTimings()
	end
end

---@return table
function GameplayController:getImporterSettings()
	local config = self.configModel.configs.settings
	return {
		midiConstantVolume = config.audio.midi.constantVolume,
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
	self.pauseModel:update()
	self.replayModel:update()
	self.rhythmModel:update()
end

function GameplayController:discordPlay()
	local rhythmModel = self.rhythmModel
	local computeContext = self.computeContext
	local chartdiff = assert(computeContext.chartdiff)
	local chartmeta = assert(computeContext.chartmeta)

	local length = math.min(chartdiff.duration, 3600 * 24)

	local timeEngine = rhythmModel.timeEngine
	self.discordModel:setPresence({
		state = "Playing",
		details = ("%s - %s [%s]"):format(chartmeta.artist, chartmeta.title, chartmeta.name),
		endTimestamp = math.floor(os.time() + (length - timeEngine.currentTime) / timeEngine.baseTimeRate),
	})
end

function GameplayController:discordPause()
	local chartmeta = assert(self.computeContext.chartmeta)
	self.discordModel:setPresence({
		state = "Playing (paused)",
		details = ("%s - %s [%s]"):format(chartmeta.artist, chartmeta.title, chartmeta.name),
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

	self.pauseModel:changePlayState(state)
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
	self.pauseModel:load()
	self.replayModel:load()
	self.resourceModel:rewind()
	self:play()
end

function GameplayController:pause()
	self.pauseModel:pause()
	self:discordPause()
end

function GameplayController:play()
	self.pauseModel:play()
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
	local scoreEngine = rhythmModel.scoreEngine
	local scoreSystem = scoreEngine.scoreSystem
	local replayBase = self.replayBase
	local computeContext = self.computeContext
	local config = self.configModel.configs.settings

	local chartmeta = assert(computeContext.chartmeta)
	local created_at = os.time()

	local replayHash = self.replayModel:saveReplay(replayBase, chartmeta, created_at, scoreEngine.pausesCount)

	local chartdiff = assert(computeContext.chartdiff)
	local chartdiff_copy = table_util.deepcopy(chartdiff)

	chartdiff.notes_preview = nil  -- fixes erasing
	chartdiff = self.cacheModel.chartdiffsRepo:createUpdateChartdiff(chartdiff)
	local judge = scoreSystem.soundsphere.judges["soundsphere"]

	local score = {
		hash = chartmeta.hash,
		index = chartmeta.index,
		modifiers = replayBase.modifiers,
		rate = replayBase.rate,
		rate_type = replayBase.rate_type,

		const = replayBase.const,
		single = replayBase.mode == "taiko",

		time = created_at,
		accuracy = scoreSystem.normalscore.accuracyAdjusted,
		max_combo = scoreSystem.base.maxCombo,
		replay_hash = replayHash,
		ratio = scoreSystem.misc.ratio,
		perfect = judge.counters.perfect,
		not_perfect = judge.counters["not perfect"],
		miss = scoreSystem.base.missCount,
		mean = scoreSystem.normalscore.normalscore.mean,
		earlylate = scoreSystem.misc.earlylate,
		pauses = scoreEngine.pausesCount,
	}
	local scoreEntry = self.cacheModel.scoresRepo:insertScore(score)

	local base = scoreSystem.base
	if base.hitCount / base.notesCount >= 0.5 then
		-- self.onlineModel.onlineScoreManager:submit(chartview, replayHash)
	end

	local chartplay = Chartplay()
	self.computeContext.chartplay = chartplay

	local chartplay_computed = rhythmModel:getChartplayComputed()

	chartplay:importChartplayBase(replayBase)
	chartplay:importChartplayComputed(chartplay_computed)

	chartplay.hash = chartmeta.hash
	chartplay.index = chartmeta.index

	chartplay.replay_hash = replayHash
	chartplay.pause_count = scoreEngine.pausesCount
	chartplay.created_at = created_at

	assert(valid.format(chartplay:validate()))

	coroutine.wrap(function()
		if not self.seaClient.connected then
			return
		end
		print("submit")
		local ok, err = self.seaClient.remote.submission:submitChartplay(chartplay, chartdiff_copy)
		print("got", ok, err)
		if ok then
			print(require("stbl").encode(ok))
		end
	end)()

	chartplay.id = scoreEntry.id

	local config = self.configModel.configs.select
	config.select_chartplay_id = config.chartplay_id
	config.chartplay_id = scoreEntry.id
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
	local input_offset, visual_offset = self.offsetModel:getInputVisual()

	self.rhythmModel:setInputOffset(input_offset)
	self.rhythmModel:setVisualOffset(visual_offset)
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
	local chartmeta = assert(self.computeContext.chartmeta)

	chartmeta.offset = chartmeta.offset or self.offsetModel:getDefaultLocal()
	chartmeta.offset = math_util.round(chartmeta.offset + delta, delta)

	self.cacheModel.chartmetasRepo:updateChartmeta({
		id = chartmeta.id,
		offset = chartmeta.offset,
	})

	self.notificationModel:notify("local offset: " .. chartmeta.offset * 1000 .. "ms")
	self:updateOffsets()
end

function GameplayController:resetLocalOffset()
	local chartmeta = assert(self.computeContext.chartmeta)

	chartmeta.offset = nil
	self.cacheModel.chartmetasRepo:updateChartmeta({
		id = chartmeta.id,
		offset = sql_util.NULL,
	})

	self.notificationModel:notify("local offset reseted: " .. self.offsetModel:getDefaultLocal() * 1000 .. "ms")

	self:updateOffsets()
end

return GameplayController
