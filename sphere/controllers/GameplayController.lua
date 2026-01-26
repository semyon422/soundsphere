local class = require("class")
local valid = require("valid")
local table_util = require("table_util")
local Chartplay = require("sea.chart.Chartplay")
local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")
local Subtimings = require("sea.chart.Subtimings")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")
local InputBinder = require("rizu.input.InputBinder")
local KeyPhysicInputEvent = require("rizu.input.KeyPhysicInputEvent")

local ResourceLoader = require("rizu.files.ResourceLoader")
local ResourceFinder = require("rizu.files.ResourceFinder")

---@class sphere.GameplayController
---@operator call: sphere.GameplayController
local GameplayController = class()

---@param rhythm_engine rizu.RhythmEngine
---@param noteSkinModel sphere.NoteSkinModel
---@param configModel sphere.ConfigModel
---@param replayModel sphere.ReplayModel
---@param multiplayerModel sphere.MultiplayerModel
---@param discordModel sphere.DiscordModel
---@param onlineModel sphere.OnlineModel
---@param cacheModel sphere.CacheModel
---@param replayBase sea.ReplayBase
---@param computeContext sea.ComputeContext
---@param pauseModel sphere.PauseModel
---@param notificationModel sphere.NotificationModel
---@param seaClient sphere.SeaClient
---@param fs fs.IFilesystem
function GameplayController:new(
	rhythm_engine,
	noteSkinModel,
	configModel,
	replayModel,
	multiplayerModel,
	discordModel,
	onlineModel,
	cacheModel,
	replayBase,
	computeContext,
	pauseModel,
	notificationModel,
	seaClient,
	fs
)
	self.rhythm_engine = rhythm_engine
	self.noteSkinModel = noteSkinModel
	self.configModel = configModel
	self.replayModel = replayModel
	self.multiplayerModel = multiplayerModel
	self.discordModel = discordModel
	self.onlineModel = onlineModel
	self.cacheModel = cacheModel
	self.replayBase = replayBase
	self.computeContext = computeContext
	self.pauseModel = pauseModel
	self.notificationModel = notificationModel
	self.seaClient = seaClient
	self.fs = fs
end

---@param chartview table
function GameplayController:load(chartview)
	self.loaded = true

	local rhythm_engine = self.rhythm_engine
	local noteSkinModel = self.noteSkinModel
	local configModel = self.configModel
	local replayModel = self.replayModel
	local pauseModel = self.pauseModel
	local replayBase = self.replayBase
	local computeContext = self.computeContext
	local fs = self.fs

	if replayModel.mode == "replay" then
		replayBase = rhythm_engine.replayBase
	end

	local config = configModel.configs.settings

	local data = assert(fs:read(chartview.location_path))
	local chart_chartmeta = assert(computeContext:fromFileData(chartview.chartfile_name, data, chartview.index or 1))
	local chart, chartmeta = chart_chartmeta.chart, chart_chartmeta.chartmeta
	computeContext:applyModifierReorder(replayBase)
	local chartdiff, state, diffcalc_context = computeContext:computeBase(replayBase)

	computeContext:applyTempo(config.gameplay.tempoFactor, config.gameplay.primaryTempo)
	if config.gameplay.autoKeySound then
		computeContext:applyAutoKeysound()
	end
	if config.gameplay.swapVelocityType then
		computeContext:swapVelocityType()
	end

	self:actualizeReplayBase()

	local input_binder = InputBinder(configModel.configs.input, chartmeta.inputmode)
	self.input_binder = input_binder

	self.resource_finder = ResourceFinder(fs)
	self.resource_loader = ResourceLoader(fs, self.resource_finder)

	self.resource_finder:reset()
	self.resource_finder:addPath(chartview.location_dir)
	self.resource_loader:load(chart.resources)

	rhythm_engine:setChart(chart, chartmeta, chartdiff)
	rhythm_engine:load()
	rhythm_engine:loadAudio(self.resource_loader.resources)

	-- constant
	rhythm_engine:setTimeToPrepare(config.gameplay.time.prepare)
	rhythm_engine:setPlayTime(chartdiff.start_time, chartdiff.duration)

	-- variable ranked
	rhythm_engine:setAdjustFactor(config.audio.adjustRate)
	rhythm_engine:setVolume(config.audio.volume)
	rhythm_engine:setLongNoteShortening(config.gameplay.longNoteShortening)
	rhythm_engine:setVisualRate(config.gameplay.speed, config.gameplay.scaleSpeed)
	rhythm_engine:setScoring(configModel.configs.select.judgements)
	rhythm_engine:setAudioMode(config.audio.mode)

	-- variable unranked
	rhythm_engine:setWindUp(state.windUp)
	rhythm_engine:setTimings(replayBase.timings, replayBase.subtimings)
	rhythm_engine:setTimingValues(replayBase.timing_values)
	rhythm_engine:setRate(replayBase.rate)
	rhythm_engine:setNearest(replayBase.nearest)
	rhythm_engine:setConst(replayBase.const)


	-- rhythmModel.inputManager.observable:add(replayModel)

	replayModel:load()
	pauseModel:load()

	local noteSkin = noteSkinModel:loadNoteSkin(tostring(chart.inputMode))
	noteSkin:loadData()
	self.noteSkin = noteSkin

	---@type rizu.ReplayFrame[]
	self.frames = {}
end

---@param timings sea.Timings
function GameplayController:setReplayBaseTimings(timings)
	local replayBase = self.replayBase
	local settings = self.configModel.configs.settings

	---@type sea.Subtimings?
	local subtimings
	local subtimings_config = settings.subtimings[timings.name]
	if subtimings_config then
		local name = subtimings_config[1]
		local value = subtimings_config[name]
		subtimings = Subtimings(name, value)
	end

	replayBase.timings = timings
	replayBase.subtimings = subtimings
	replayBase.timing_values = assert(TimingValuesFactory:get(timings, subtimings))
end

function GameplayController:actualizeReplayBaseTimings()
	local chartmeta = assert(self.computeContext.chartmeta)
	local settings = self.configModel.configs.settings

	local timings = chartmeta.timings
	timings = timings or Timings(unpack(settings.format_timings[chartmeta.format]))
	self:setReplayBaseTimings(timings)

	if chartmeta.timings then
		self.replayBase.timings = nil
	end
end

function GameplayController:actualizeReplayBase()
	local config = self.configModel.configs.settings.replay_base

	if config.auto_timings then
		self:actualizeReplayBaseTimings()
	end
end

function GameplayController:unload()
	self.loaded = false

	self.discordModel:setPresence({})
	self:skip()

	if self:hasResult() then
		self:saveScore()
	end

	-- local rhythmModel = self.rhythmModel
	-- rhythmModel:unloadAllEngines()
	-- rhythmModel.inputManager:setMode("external")
	self.replayModel:setMode("record")

	self.rhythm_engine:unload()
end

---@param dt number
function GameplayController:update(dt)
	self.pauseModel:update()
	-- self.replayModel:update()
	-- self.rhythmModel:update()
	self.rhythm_engine:update()
end

function GameplayController:discordPlay()
	local computeContext = self.computeContext
	local chartdiff = assert(computeContext.chartdiff)
	local chartmeta = assert(computeContext.chartmeta)

	local length = math.min(chartdiff.duration, 3600 * 24)

	-- self.discordModel:setPresence({
	-- 	state = "Playing",
	-- 	details = ("%s - %s [%s]"):format(chartmeta.artist, chartmeta.title, chartmeta.name),
	-- 	endTimestamp = math.floor(os.time() + (length - timeEngine.currentTime) / timeEngine.baseTimeRate),
	-- })
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
	if self.multiplayerModel.client:isInRoom() then
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
	local physic_event = KeyPhysicInputEvent.fromInputChangedEvent(event)
	if physic_event then
		local virtual_event = self.input_binder:transform(physic_event)
		if virtual_event then
			self.rhythm_engine:receive(virtual_event)
			table.insert(self.frames, {
				time = self.rhythm_engine:getTime(),
				event = virtual_event
			})
		end
	end

	if event.name == "framestarted" then
		self.rhythm_engine:setGlobalTime(event.time)
		return
	end
end

function GameplayController:retry()
	local replayBase = self.replayBase

	-- rhythmModel.inputManager:setMode("external")
	self.replayModel:setMode("record")

	self.pauseModel:load()
	self.replayModel:load()
	-- self.resourceModel:rewind()

	local timings = assert(replayBase.timings or self.computeContext.chartmeta.timings)
	self.rhythm_engine.score_engine:createByTimings(timings, replayBase.subtimings, true)

	self.rhythm_engine:retry()

	self:play()
end

function GameplayController:pause()
	self.rhythm_engine:pause()
	self:discordPause()
end

function GameplayController:play()
	self.rhythm_engine:play()
	self:discordPlay()
end

---@return boolean
function GameplayController:hasResult()
	return self.rhythm_engine:hasResult() and self.replayModel.mode ~= "replay"
end

function GameplayController:saveScore()
	local rhythm_engine = self.rhythm_engine
	local rhythm_engine = self.rhythm_engine
	local pause_counter = rhythm_engine.pause_counter
	local scoreEngine = rhythm_engine.score_engine
	local replayBase = self.replayBase
	local computeContext = self.computeContext

	local chartmeta = assert(computeContext.chartmeta)
	local created_at = os.time()

	local replay, replay_hash = self.replayModel:saveReplay(
		replayBase,
		chartmeta,
		created_at,
		pause_counter.count
	)

	local chartdiff = assert(computeContext.chartdiff)
	local chartdiff_copy = setmetatable(table_util.deepcopy(chartdiff), getmetatable(chartdiff))

	chartdiff = self.cacheModel.chartsRepo:createUpdateChartdiff(chartdiff, created_at)

	local chartplay = Chartplay()

	local chartplay_computed = rhythm_engine:getChartplayComputed()

	chartplay:importChartplayBase(replay)
	chartplay:importChartplayComputed(chartplay_computed)

	chartplay.hash = chartmeta.hash
	chartplay.index = chartmeta.index

	chartplay.replay_hash = replay_hash
	chartplay.pause_count = pause_counter.count
	chartplay.created_at = created_at

	assert(valid.format(chartplay:validate()))
	local chartplay_copy = setmetatable(table_util.deepcopy(chartplay), Chartplay)

	chartplay.user_id = 1
	chartplay.compute_state = "valid"
	chartplay.computed_at = created_at
	chartplay.submitted_at = created_at

	local _chartplay = self.cacheModel.chartsRepo:createChartplay(chartplay)
	computeContext.chartplay = _chartplay

	local function submit()
		if not self.seaClient.connected then
			return
		end

		local base = scoreEngine.scores.base
		if base.hitCount / base.notesCount < 0.5 then
			print("not submitted")
			return
		end

		print("submit")
		local ok, err = self.seaClient.remote.submission:submitChartplay(chartplay_copy, chartdiff_copy)
		print("got", ok, err)
		if ok then
			print(require("stbl").encode(ok))
		else
			print("dumping events")
			local data = require("string.buffer").encode(self.rhythm_engine.score_engine.events)
			self.fs:write("events.bin", data)
		end
	end

	coroutine.wrap(function()
		local ok, err = xpcall(submit, debug.traceback)
		if not ok then
			print("submit error", err)
		end
	end)()

	local config = self.configModel.configs.select
	config.select_chartplay_id = config.chartplay_id
	config.chartplay_id = _chartplay.id
end

function GameplayController:skip()
	-- local rhythmModel = self.rhythmModel
	-- local timeEngine = rhythmModel.timeEngine

	-- self:update(0)

	-- rhythmModel.audioEngine:unload()
	-- timeEngine:play()
	-- timeEngine.currentTime = math.huge
	-- self.replayModel:update()
	-- rhythmModel.logicEngine:update()
end

function GameplayController:skipIntro()
	-- self.rhythmModel.timeEngine:skipIntro()
end

return GameplayController
