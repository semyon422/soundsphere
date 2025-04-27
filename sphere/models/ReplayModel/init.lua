local class = require("class")
local valid = require("valid")
local md5 = require("md5")
local path_util = require("path_util")
local Osr = require("osu.Osr")
local Replay = require("sea.replays.Replay")
local ReplayCoder = require("sea.replays.ReplayCoder")
local ReplayEvents = require("sea.replays.ReplayEvents")
local ReplayConverter = require("sea.replays.ReplayConverter")

---@class sphere.ReplayModel
---@operator call: sphere.ReplayModel
---@field events sea.ReplayEvent[]
local ReplayModel = class()

ReplayModel.path = "userdata/replays"
ReplayModel.mode = "record"

---@param rhythmModel sphere.RhythmModel
function ReplayModel:new(rhythmModel)
	self.rhythmModel = rhythmModel
	self.events = {}
	self.eventOffset = 0
end

function ReplayModel:load()
	if self.mode == "record" then
		self.events = {}
	elseif self.mode == "replay" then
		self.eventOffset = 0
	end
	self.inputsMap = self.rhythmModel.chart.inputMode:getInputMap()
	self.inputs = self.rhythmModel.chart.inputMode:getInputs()
end

---@param data string
function ReplayModel:decodeEvents(data)
	self.events = assert(ReplayEvents.decode(data))
end

function ReplayModel:step()
	self.eventOffset = math.min(self.eventOffset + 1, #self.events)
end

---@return sea.ReplayEvent?
function ReplayModel:getNextEvent()
	return self.events[self.eventOffset + 1]
end

---@param mode string
function ReplayModel:setMode(mode)
	self.mode = mode
end

---@param event table
function ReplayModel:receive(event)
	if self.mode == "record" and event.virtual then
		table.insert(self.events, {
			event.time - self.rhythmModel.logicEngine.inputOffset,
			self.inputsMap[event[1]],
			not not event.name:find("pressed"),
		})
	end
end

---@return nil?
function ReplayModel:update()
	if self.mode ~= "replay" then
		return
	end

	local _event = self:getNextEvent()
	if not _event then
		return
	end

	local event = {
		name = _event[3] and "keypressed" or "keyreleased",
		time = _event[1],
		virtual = true,
		self.inputs[_event[2]]
	}

	local rhythmModel = self.rhythmModel
	local timeEngine = rhythmModel.timeEngine
	local logicEngine = rhythmModel.logicEngine

	event.baseTime = event.baseTime or event.time
	event.time = event.baseTime + logicEngine.inputOffset
	if timeEngine.currentTime >= event.time then
		rhythmModel:receive(event)
		self:step()
		return self:update()
	end
end

---@param replayBase sea.ReplayBase
---@param chartmetaKey sea.ChartmetaKey
---@param created_at integer
---@param pause_count integer
---@param auto_timings boolean
---@return sea.Replay
---@return string
---@return string
function ReplayModel:createReplay(replayBase, chartmetaKey, created_at, pause_count, auto_timings)
	local replay = Replay()

	replay:importReplayBase(replayBase)
	replay:importChartmetaKey(chartmetaKey)

	if auto_timings then
		replay.timings = nil
	end

	replay.healths = nil

	replay.version = 1
	replay.timing_values = replayBase.timing_values
	replay.events = assert(ReplayEvents.encode(self.events))
	replay.created_at = created_at

	replay.pause_count = pause_count

	assert(valid.format(replay:validate()))

	local data = assert(ReplayCoder.encode(replay))
	local replay_hash = md5.sumhexa(data)

	self.replay = replay

	return replay, data, replay_hash
end

---@param replayBase sea.ReplayBase
---@param chartmetaKey sea.ChartmetaKey
---@param created_at integer
---@param pause_count integer
---@param auto_timings boolean
---@return sea.Replay
---@return string
function ReplayModel:saveReplay(replayBase, chartmetaKey, created_at, pause_count, auto_timings)
	local replay, data, hash = self:createReplay(replayBase, chartmetaKey, created_at, pause_count, auto_timings)
	assert(love.filesystem.write(self.path .. "/" .. hash, data))
	return replay, hash
end

---@param chartmeta sea.Chartmeta
function ReplayModel:saveOsr(chartmeta)
	local replay = self.replay

	local osr = Osr()

	osr.beatmap_hash = assert(replay.hash)

	local inputMap = replay.inputMode:getInputMap()

	local mania_events = {}
	for i, e in ipairs(replay.events) do
		mania_events[i] = {
			math.floor(e.time * 1000),
			inputMap[e[1]],
			not not e.name:find("pressed")
		}
	end
	osr:encodeManiaEvents(mania_events)
	osr:setTimestamp(replay.time)
	osr.player_name = replay.player

	local data = osr:encode()

	local display_title = ("%s - %s [%s]"):format(
		chartmeta.artist, chartmeta.title, chartmeta.name
	)

	local name = ("%s - %s (%s) OsuMania.osr"):format(
		osr.player_name,
		display_title,
		os.date("%Y-%m-%d", osr:getTimestamp())
	)

	love.filesystem.write(path_util.join("userdata", "export", name), data)
end

---@param data string
---@return sea.Replay?
function ReplayModel:loadReplay(data)
	self.replay = nil

	if not data then
		return
	end

	local replay = ReplayCoder.decode(data)
	if not replay then
		return
	end

	replay = ReplayConverter:convert(replay)

	assert(valid.format(replay:validate()))

	self.replay = replay

	return replay
end

return ReplayModel
