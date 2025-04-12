local md5 = require("md5")
local valid = require("valid")
local Replay = require("sea.replays.Replay")
local ReplayCoder = require("sea.replays.ReplayCoder")
local ReplayEvents = require("sea.replays.ReplayEvents")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local Healths = require("sea.chart.Healths")

local test = {}

local chartfile_data = [[
# metadata
title Title
artist Artist
name Name
creator Creator
audio audio.mp3
input 4key

# notes
1000 =0
- =1
]]

---@param t testing.T
function test.all(t)
	local events = {
		{0, 1, true},
		{1, 1, false},
	}

	local replay = {
		version = 1,
		timing_values = TimingValuesFactory:get(Timings("sphere"), Subtimings("none")),
		events = ReplayEvents.encode(events),
		created_at = 0,
		--
		hash = md5.sumhexa(chartfile_data),
		index = 1,
		modifiers = {},
		rate = 1,
		mode = "mania",
		--
		nearest = true,
		tap_only = false,
		timings = Timings("sphere"),
		subtimings = Subtimings("none"),
		healths = Healths("simple", 20),
		columns_order = nil,
		--
		custom = false,
		const = false,
		pause_count = 0,
		rate_type = "linear",
	}
	setmetatable(replay, Replay)
	---@cast replay sea.Replay

	t:assert(valid.format(replay:validate()))

	local replayfile_data = t:assert(ReplayCoder.encode(replay))

	local _replay = t:assert(ReplayCoder.decode(replayfile_data))

	t:assert(valid.format(_replay:validate()))

	t:tdeq(_replay, replay)
end

return test
