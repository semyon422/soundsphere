local class = require("class")
local math_util = require("math_util")
local sql_util = require("rdb.sql_util")
local InputMode = require("ncdk.InputMode")
local TempoRange = require("notechart.TempoRange")
local ModifierModel = require("sphere.models.ModifierModel")
local Note = require("ncdk2.notes.Note")
local Chartplay = require("sea.chart.Chartplay")
local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")

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
---@param playContext sphere.PlayContext
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
	playContext,
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
	self.playContext = playContext
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
	local playContext = self.playContext

	local chartview = self.selectModel.chartview
	local config = configModel.configs.settings
	local judgement = configModel.configs.select.judgements

	local chart = selectModel:loadChartAbsolute(self:getImporterSettings())

	self:applyTempo(chart, config.gameplay.tempoFactor, config.gameplay.primaryTempo)
	if config.gameplay.autoKeySound then
		self:applyAutoKeysound(chart)
	end
	if config.gameplay.swapVelocityType then
		self:swapVelocityType(chart)
	end

	local state = {}
	state.inputMode = InputMode(chart.inputMode)

	ModifierModel:applyMeta(playContext.modifiers, state)
	ModifierModel:apply(playContext.modifiers, chart)

	local chartdiff = {
		rate = playContext.rate,
		inputmode = tostring(chart.inputMode),
		notes_preview = "",  -- do not generate preview
	}
	cacheModel.chartdiffGenerator.difficultyModel:compute(chartdiff, chart, playContext.rate)

	chartdiff.modifiers = playContext.modifiers
	chartdiff.hash = chartview.hash
	chartdiff.index = chartview.index
	chartdiff.rate_type = config.gameplay.rate_type
	cacheModel.chartdiffGenerator:fillMeta(chartdiff, chartview)
	playContext.chartdiff = chartdiff
	chart.chartdiff = chartdiff

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

	rhythmModel:setNoteChart(chart)
	rhythmModel:setDrawRange(noteSkin.range)
	rhythmModel.inputManager:setInputMode(tostring(chart.inputMode))

	rhythmModel:setWindUp(state.windUp)
	rhythmModel:setTimeRate(playContext.rate)
	rhythmModel:setConstantSpeed(playContext.const)
	rhythmModel:setTimings(playContext.timings)
	rhythmModel:setSingleHandler(playContext.single)

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

---@param chart ncdk2.Chart
---@param tempo number
local function applyTempo(chart, tempo)
	for _, visual in ipairs(chart:getVisuals()) do
		visual.primaryTempo = tempo
		visual:compute()
	end
end

---@param chart ncdk2.Chart
function GameplayController:swapVelocityType(chart)
	for _, visual in ipairs(chart:getVisuals()) do
		visual.tempoMultiplyTarget = "local"
		for _, vp in ipairs(visual.points) do
			local vel = vp._velocity
			if vel then
				vel.localSpeed, vel.currentSpeed = vel.currentSpeed, vel.localSpeed
			end
		end
		visual:compute()
	end
end

---@param tempoFactor string
function GameplayController:applyTempo(noteChart, tempoFactor, primaryTempo)
	if tempoFactor == "primary" then
		applyTempo(noteChart, primaryTempo)
		return
	end

	if tempoFactor == "average" and noteChart.chartmeta.tempo_avg then
		applyTempo(noteChart, noteChart.chartmeta.tempo_avg)
		return
	end

	local minTime = noteChart.chartmeta.start_time
	local maxTime = minTime + noteChart.chartmeta.duration

	local t = {}
	t.average, t.minimum, t.maximum = TempoRange:find(noteChart, minTime, maxTime)

	applyTempo(noteChart, t[tempoFactor])
end

---@param chart ncdk2.Chart
function GameplayController:applyAutoKeysound(chart)
	for _, note in chart.notes:iter() do
		if note.type == "note" or note.type == "hold" then
			local soundNote = chart.notes:get(note.visualPoint, "auto")
			if not soundNote then
				soundNote = Note(note.visualPoint, "auto", "sample")
				chart.notes:insert(soundNote)
				soundNote.sounds = {}
			end

			if note.sounds then
				for _, t in ipairs(note.sounds) do
					table.insert(soundNote.sounds, t)
				end
				note.sounds = {}
			end
		end
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
	local chartview = self.selectModel.chartview
	local rhythmModel = self.rhythmModel
	local length = math.min(chartview.duration, 3600 * 24)

	local timeEngine = rhythmModel.timeEngine
	self.discordModel:setPresence({
		state = "Playing",
		details = ("%s - %s [%s]"):format(chartview.artist, chartview.title, chartview.name),
		endTimestamp = math.floor(os.time() + (length - timeEngine.currentTime) / timeEngine.baseTimeRate),
	})
end

function GameplayController:discordPause()
	local chartview = self.selectModel.chartview
	self.discordModel:setPresence({
		state = "Playing (paused)",
		details = ("%s - %s [%s]"):format(chartview.artist, chartview.title, chartview.name),
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
	local playContext = self.playContext

	local chartview = self.selectModel.chartview

	local replayHash = self.replayModel:saveReplay(self.playContext.chartdiff, playContext)

	local chartdiff = self.playContext.chartdiff
	chartdiff.notes_preview = nil  -- fixes erasing
	chartdiff = self.cacheModel.chartdiffsRepo:createUpdateChartdiff(chartdiff)
	local judge = scoreSystem.soundsphere.judges["soundsphere"]

	local score = {
		hash = chartdiff.hash,
		index = chartdiff.index,
		modifiers = chartdiff.modifiers,
		rate = chartdiff.rate,
		rate_type = chartdiff.rate_type,

		const = playContext.const,
		-- timings = playContext.timings,
		single = playContext.single,

		time = os.time(),
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
		self.onlineModel.onlineScoreManager:submit(chartview, replayHash)
	end

	local chartplay = Chartplay()

	-- chartplay.user_id = 0
	chartplay.events_hash = replayHash
	-- chartplay.notes_hash = ""
	chartplay.hash = chartdiff.hash
	chartplay.index = chartdiff.index
	chartplay.modifiers = {}
	chartplay.custom = true
	chartplay.rate = chartdiff.rate
	chartplay.rate_type = chartdiff.rate_type
	chartplay.mode = "mania"
	chartplay.const = playContext.const
	chartplay.nearest = playContext.timings.nearest
	chartplay.tap_only = false -- like NoLongNote
	chartplay.timings = Timings("simple", 100)
	chartplay.healths = Healths("simple", 20)
	chartplay.columns_order = nil
	chartplay.created_at = os.time()
	-- chartplay.submitted_at = integer
	-- chartplay.computed_at = integer
	-- chartplay.compute_state = sea.ComputeState
	chartplay.pause_count = scoreEngine.pausesCount
	chartplay.result = "pass"
	chartplay.judges = {}
	chartplay.accuracy = 0.020
	chartplay.max_combo = 0
	chartplay.perfect_count = judge.counters.perfect
	chartplay.miss_count = scoreSystem.base.missCount
	chartplay.rating = 0
	chartplay.accuracy_osu = 0
	chartplay.accuracy_etterna = 0
	chartplay.rating_pp = 0
	chartplay.rating_msd = 0

	coroutine.wrap(function()
		if not self.seaClient.connected then
			return
		end
		print("submit")
		local ok, err = self.seaClient.remote.submission:submitChartplay(chartplay)
		print("got", ok, err)
		if ok then
			print(require("stbl").encode(ok))
		end
	end)()

	self.playContext.scoreEntry = scoreEntry

	local config = self.configModel.configs.select
	config.select_score_id = config.score_id
	config.score_id = scoreEntry.id
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
	local chartview = self.selectModel.chartview

	chartview.offset = chartview.offset or self.offsetModel:getDefaultLocal()
	chartview.offset = math_util.round(chartview.offset + delta, delta)

	self.cacheModel.chartmetasRepo:updateChartmeta({
		id = chartview.chartmeta_id,
		offset = chartview.offset,
	})

	self.notificationModel:notify("local offset: " .. chartview.offset * 1000 .. "ms")
	self:updateOffsets()
end

function GameplayController:resetLocalOffset()
	local chartview = self.selectModel.chartview

	chartview.offset = nil
	self.cacheModel.chartmetasRepo:updateChartmeta({
		id = chartview.chartmeta_id,
		offset = sql_util.NULL,
	})

	self.notificationModel:notify("local offset reseted: " .. self.offsetModel:getDefaultLocal() * 1000 .. "ms")

	self:updateOffsets()
end

return GameplayController
