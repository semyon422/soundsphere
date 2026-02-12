local table_util = require("table_util")
local GameplayTimings = require("rizu.gameplay.GameplayTimings")
local SettingsConfig = require("sphere.persistence.ConfigModel.settings")
local ReplayBase = require("sea.replays.ReplayBase")
local Chartmeta = require("sea.chart.Chartmeta")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")

local test = {}

---@param t testing.T
function test.no_auto_timings(t)
	local replayBase = ReplayBase()
	local chartmeta = Chartmeta()
	local config = table_util.deepcopy(SettingsConfig)

	config.replay_base.auto_timings = false
	replayBase.timings = Timings("osuod", 5)
	chartmeta.timings = Timings("osuod", 10)

	GameplayTimings(config, chartmeta):apply(replayBase)

	t:eq(replayBase.timings, Timings("osuod", 5))
	t:eq(replayBase.subtimings, nil) -- not valid, but it is managed by user in this case
end

---@param t testing.T
function test.auto_timings_from_chart(t)
	local replayBase = ReplayBase()
	local chartmeta = Chartmeta()
	local config = table_util.deepcopy(SettingsConfig)

	config.replay_base.auto_timings = true
	replayBase.timings = Timings("osuod", 5)
	chartmeta.timings = Timings("osuod", 10)

	GameplayTimings(config, chartmeta):apply(replayBase)

	t:eq(replayBase.timings, nil)
	t:eq(replayBase.subtimings, Subtimings('scorev', 1))
end

---@param t testing.T
function test.auto_timings_from_format(t)
	local replayBase = ReplayBase()
	local chartmeta = Chartmeta()
	local config = table_util.deepcopy(SettingsConfig)

	config.replay_base.auto_timings = true
	replayBase.timings = Timings("osuod", 5)
	chartmeta.format = "quaver"

	GameplayTimings(config, chartmeta):apply(replayBase)

	t:eq(replayBase.timings, Timings("quaver")) -- always not nil if chartmeta.timings is nil
	t:eq(replayBase.subtimings, nil)
end

return test
