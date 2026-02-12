local class = require("class")
local GameplayChart = require("rizu.gameplay.GameplayChart")
local GameplayTimings = require("rizu.gameplay.GameplayTimings")
local RhythmEngineLoader = require("rizu.gameplay.RhythmEngineLoader")
local InputBinder = require("rizu.input.InputBinder")
local KeyPhysicInputEvent = require("rizu.input.KeyPhysicInputEvent")
local ReplayPlayer = require("rizu.engine.replay.ReplayPlayer")

---@class rizu.GameplayInteractor
---@operator call: rizu.GameplayInteractor
local GameplayInteractor = class()

---@param game sphere.GameController
function GameplayInteractor:new(game)
	self.game = game
end

function GameplayInteractor:loadGameplay(chartview)
	local game = self.game

	GameplayChart(
		game.configModel.configs.settings,
		game.replayBase,
		game.computeContext,
		game.fs,
		chartview
	):load()

	local chart = assert(game.computeContext.chart)
	local chartmeta = assert(game.computeContext.chartmeta)

	if not self.replaying then
		GameplayTimings(
			game.configModel.configs.settings,
			game.replayBase,
			chartmeta
		):load()
	end

	game.resource_finder:reset()
	game.resource_finder:addPath(chartview.location_dir)
	game.resource_loader:load(chart.resources)

	RhythmEngineLoader(
		game.rhythm_engine,
		game.replayBase,
		game.computeContext,
		game.configModel.configs.settings,
		game.resource_loader.resources
	):loadEngine()

	local input_binder = InputBinder(game.configModel.configs.input, chartmeta.inputmode)
	self.input_binder = input_binder

	game.pauseModel:load()

	local noteSkin = game.noteSkinModel:loadNoteSkin(tostring(chart.inputMode))
	noteSkin:loadData()
	self.noteSkin = noteSkin

	---@type rizu.ReplayFrame[]
	self.frames = {}

	game.multiplayerModel.client:setPlaying(true)
	game.offsetController:updateOffsets()

	local fileFinder = game.fileFinder
	fileFinder:reset()

	if game.configModel.configs.settings.gameplay.skin_resources_top_priority then
		fileFinder:addPath(noteSkin.directoryPath)
		fileFinder:addPath(chartview.location_dir)
	else
		fileFinder:addPath(chartview.location_dir)
		fileFinder:addPath(noteSkin.directoryPath)
	end
	fileFinder:addPath("userdata/hitsounds")
	fileFinder:addPath("userdata/hitsounds/midi")

	game.rhythm_engine:setGlobalTime(game.global_timer:getTime())
	self:play()

	self.loaded = true
end

---@param frames rizu.ReplayFrame[]
function GameplayInteractor:setReplayFrames(frames)
	self.replay_player = ReplayPlayer(frames)
end

function GameplayInteractor:unloadGameplay()
	self.loaded = false
	local game = self.game

	game.discordModel:setPresence({})
	self:skip()

	if self:hasResult() then
		self:saveScore()
	end

	game.rhythm_engine:unload()
	game.multiplayerModel.client:setPlaying(false)
end

function GameplayInteractor:update()
	if not self.loaded then
		return
	end

	local game = self.game

	game.rhythm_engine:setGlobalTime(game.global_timer:getTime())

	local replay_player = self.replay_player
	if self.replaying and replay_player then
		local next_time = game.rhythm_engine:getTime(true)
		local offset = game.rhythm_engine.logic_offset
		local replay_to = next_time - offset
		local frame = replay_player:play(replay_to)
		while frame do
			game.rhythm_engine:setTimeNoAudio(frame.time + offset)
			game.rhythm_engine:receive(frame.event)
			frame = replay_player:play(replay_to)
		end
		assert(next_time >= game.rhythm_engine:getTime(true))
		game.rhythm_engine:setTimeNoAudio(next_time)
	end

	game.rhythm_engine:update()

	game.pauseModel:update()
end

---@param delta number
function GameplayInteractor:increasePlaySpeed(delta)
	local game = self.game

	local speedModel = game.speedModel
	speedModel:increase(delta)

	local gameplay = game.configModel.configs.settings.gameplay
	game.rhythm_engine:setVisualRate(gameplay.speed)
	game.notificationModel:notify("scroll speed: " .. speedModel.format[gameplay.speedType]:format(speedModel:get()))
end

---@return boolean
function GameplayInteractor:hasResult()
	local game = self.game
	return game.rhythm_engine:hasResult() and not self.replaying
end

function GameplayInteractor:play()
	local game = self.game
	game.rhythm_engine:play()
	-- self:discordPlay()
end

function GameplayInteractor:pause()
	local game = self.game
	game.rhythm_engine:pause()
	-- self:discordPause()
end

function GameplayInteractor:retry()
	local game = self.game
	local replayBase = game.replayBase

	self.replaying = false

	game.pauseModel:load()
	-- self.resourceModel:rewind()

	game.rhythm_engine:retry()
	game.rhythm_engine:setTimings(replayBase.timings, replayBase.subtimings)

	self:play()
end

function GameplayInteractor:skipIntro()
	-- self.rhythmModel.timeEngine:skipIntro()
end

function GameplayInteractor:skip()
	-- self.rhythmModel.timeEngine:skipIntro()
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
	if self.replaying then
		return
	end

	local game = self.game
	local physic_event = KeyPhysicInputEvent.fromInputChangedEvent(event)
	if physic_event then
		local virtual_event = self.input_binder:transform(physic_event)
		if virtual_event then
			game.rhythm_engine:setGlobalTime(game.global_timer:getTime())
			game.rhythm_engine:receive(virtual_event)
			table.insert(self.frames, {
				time = game.rhythm_engine:getTime(),
				event = virtual_event
			})
		end
	end
end

return GameplayInteractor
