local class = require("class")
local valid = require("valid")
local md5 = require("md5")
local Replay = require("sea.replays.Replay")
local ReplayCoder = require("sea.replays.ReplayCoder")

---@class rizu.ReplayFactory
---@operator call: rizu.ReplayFactory
local ReplayFactory = class()

---@param replayBase sea.ReplayBase
---@param chartmetaKey sea.ChartmetaKey
---@param frames rizu.ReplayFrame[]
---@param created_at integer
---@param pause_count integer
---@return sea.Replay
---@return string
---@return string
function ReplayFactory:createReplay(replayBase, chartmetaKey, frames, created_at, pause_count)
	local replay = Replay()

	replay:importReplayBase(replayBase)
	replay:importChartmetaKey(chartmetaKey)

	replay.healths = nil

	replay.version = 2
	replay.timing_values = replayBase.timing_values
	replay.frames = frames
	replay.created_at = created_at
	replay.pause_count = pause_count

	assert(valid.format(replay:validate()))

	local data = assert(ReplayCoder.encode(replay))
	local replay_hash = md5.sumhexa(data)

	return replay, data, replay_hash
end

return ReplayFactory
