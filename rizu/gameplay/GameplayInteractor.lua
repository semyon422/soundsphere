local class = require("class")
local GameplayChart = require("rizu.gameplay.GameplayChart")
local GameplayTimings = require("rizu.gameplay.GameplayTimings")
local RhythmEngineLoader = require("rizu.gameplay.RhythmEngineLoader")
local InputBinder = require("rizu.input.InputBinder")
local KeyPhysicInputEvent = require("rizu.input.KeyPhysicInputEvent")

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

	GameplayTimings(
		game.configModel.configs.settings,
		game.replayBase,
		chartmeta
	):load()

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

	local chartmeta = assert(game.computeContext.chartmeta)

	local input_binder = InputBinder(game.configModel.configs.input, chartmeta.inputmode)
	self.input_binder = input_binder

	-- replayModel:load()
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

	self.loaded = true
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
	game.pauseModel:update()
	game.rhythm_engine:update()
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
	return game.rhythm_engine:hasResult() -- and game.replayModel.mode ~= "replay"
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

	-- rhythmModel.inputManager:setMode("external")
	-- self.replayModel:setMode("record")

	game.pauseModel:load()
	-- self.replayModel:load()
	-- self.resourceModel:rewind()

	local timings = assert(replayBase.timings or game.computeContext.chartmeta.timings)
	game.rhythm_engine.score_engine:createByTimings(timings, replayBase.subtimings, true)

	game.rhythm_engine:retry()

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
	local game = self.game
	local physic_event = KeyPhysicInputEvent.fromInputChangedEvent(event)
	if physic_event then
		local virtual_event = self.input_binder:transform(physic_event)
		if virtual_event then
			game.rhythm_engine:receive(virtual_event)
			table.insert(self.frames, {
				time = game.rhythm_engine:getTime(),
				event = virtual_event
			})
		end
	end

	if event.name == "framestarted" then
		game.rhythm_engine:setGlobalTime(event.time)
		return
	end
end

return GameplayInteractor
