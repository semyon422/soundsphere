local class = require("class")
local GameplayChart = require("rizu.gameplay.GameplayChart")
local GameplayTimings = require("rizu.gameplay.GameplayTimings")
local RhythmEngineLoader = require("rizu.gameplay.RhythmEngineLoader")
local InputBinder = require("rizu.input.InputBinder")
local KeyPhysicInputEvent = require("rizu.input.KeyPhysicInputEvent")
local GameplaySession = require("rizu.gameplay.GameplaySession")
local ScoreSaver = require("rizu.gameplay.ScoreSaver")

---@class rizu.GameplayInteractor
---@operator call: rizu.GameplayInteractor
local GameplayInteractor = class()

---@param game sphere.GameController
function GameplayInteractor:new(game)
	self.game = game
	self.replaying = false
	self.autoplay = false
	self.audio_disabled = false

	self.score_saver = ScoreSaver(
		game.fs,
		game.persistence.cacheModel,
		game.persistence.configModel,
		game.seaClient,
		game.replayBase,
		game.computeContext
	)
end

function GameplayInteractor:loadGameplay(chartview)
	local game = self.game

	GameplayChart(game.configModel.configs.settings, game.fs, chartview):load(game.replayBase, game.computeContext)

	local chart = assert(game.computeContext.chart)
	local chartmeta = assert(game.computeContext.chartmeta)

	if not self.replaying then
		GameplayTimings(game.configModel.configs.settings, chartmeta):apply(game.replayBase)
	end

	local noteSkin = game.noteSkinModel:loadNoteSkin(tostring(chart.inputMode))
	noteSkin:loadData()
	self.noteSkin = noteSkin

	game.resource_finder:reset()
	game.fileFinder:reset()

	local paths = {}
	if game.configModel.configs.settings.gameplay.skin_resources_top_priority then
		table.insert(paths, noteSkin.directoryPath)
		table.insert(paths, chartview.location_dir)
	else
		table.insert(paths, chartview.location_dir)
		table.insert(paths, noteSkin.directoryPath)
	end
	table.insert(paths, "userdata/hitsounds")
	table.insert(paths, "userdata/hitsounds/midi")

	for _, path in ipairs(paths) do
		game.resource_finder:addPath(path)
		game.fileFinder:addPath(path)
	end

	game.resource_loader:load(chart.resources)

	self:load(self.autoplay)

	local input_binder = InputBinder(game.configModel.configs.input, chartmeta.inputmode)
	self.input_binder = input_binder

	game.pauseModel:load()

	game.multiplayerModel.client:setPlaying(true)
	game.offsetController:updateOffsets()

	self:play()

	self.loaded = true
end

---@param autoplay boolean?
function GameplayInteractor:load(autoplay)
	local game = self.game

	game:recreateRhythmEngine()

	local loader = RhythmEngineLoader(
		game.replayBase,
		game.computeContext,
		game.configModel.configs.settings,
		game.resource_loader.resources
	)
	loader:setAudioEnabled(not self.audio_disabled)
	loader:load(game.rhythm_engine)

	self.gameplay_session = GameplaySession(game.rhythm_engine)
	
	local play_type = "manual"
	if self.replaying then
		play_type = "replay"
	elseif autoplay then
		play_type = "auto"
	end
	
	self.gameplay_session:setPlayType(play_type)
	if play_type == "replay" and self.replay_frames then
		self.gameplay_session:setReplayFrames(self.replay_frames)
	end

	game.rhythm_engine:setGlobalTime(game.global_timer:getTime())
end

---@param frames rizu.ReplayFrame[]
function GameplayInteractor:setReplayFrames(frames)
	self.replay_frames = frames
	if self.gameplay_session then
		self.gameplay_session:setReplayFrames(frames)
	end
end

function GameplayInteractor:unloadGameplay()
	self.loaded = false
	self.replaying = false
	self.autoplay = false
	local game = self.game

	game.discordModel:setPresence({})
	self:skip()

	game.rhythm_engine:unloadAudio()

	if self:hasResult() then
		self:saveScore()
	end

	game.multiplayerModel.client:setPlaying(false)
end

function GameplayInteractor:update()
	if not self.loaded then
		return
	end

	local game = self.game
	self.gameplay_session:update(game.global_timer:getTime())
	game.pauseModel:update()
end

---@param delta number
function GameplayInteractor:increasePlaySpeed(delta)
	local game = self.game

	local speedModel = game.speedModel
	speedModel:increase(delta)

	local gameplay = game.configModel.configs.settings.gameplay
	game.rhythm_engine:setVisualRate(gameplay.speed, gameplay.scaleSpeed)
	game.notificationModel:notify("scroll speed: " .. speedModel.format[gameplay.speedType]:format(speedModel:get()))
end

---@return boolean
function GameplayInteractor:hasResult()
	return self.gameplay_session:hasResult()
end

function GameplayInteractor:saveScore()
	self.score_saver:saveScore(self.gameplay_session)
end

function GameplayInteractor:play()
	self.gameplay_session:play(true)
	-- self:discordPlay()
end

function GameplayInteractor:pause()
	self.gameplay_session:pause()
	-- self:discordPause()
end

function GameplayInteractor:retry()
	local game = self.game
	local replayBase = game.replayBase

	game.pauseModel:load()
	-- self.resourceModel:rewind()

	self:load(self.autoplay)

	game.rhythm_engine:setTimings(replayBase.timings, replayBase.subtimings)
	self:play()
end

function GameplayInteractor:skipIntro()
	self.gameplay_session:skipIntro()
end

function GameplayInteractor:skip()
	self.game.rhythm_engine:setTime(math.huge)
end

---@param state "play"|"pause"|"retry"
function GameplayInteractor:changePlayState(state)
	local game = self.game
	if game.multiplayerModel.client:isInRoom() then
		return
	end

	-- if state == "play" then
	-- 	self:discordPlay()
	-- elseif state == "pause" then
	-- 	self:discordPause()
	-- end

	game.pauseModel:changePlayState(state)
end

---@param event table
function GameplayInteractor:receive(event)
	local game = self.game
	local physic_event = KeyPhysicInputEvent.fromInputChangedEvent(event)
	if physic_event then
		local virtual_event = self.input_binder:transform(physic_event)
		if virtual_event then
			self.gameplay_session:receive(virtual_event, game.global_timer:getTime())
		end
	end
end

return GameplayInteractor
