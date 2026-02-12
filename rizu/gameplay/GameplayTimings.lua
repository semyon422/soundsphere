local class = require("class")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")

---@class rizu.GameplayTimings
---@operator call: rizu.GameplayTimings
local GameplayTimings = class()

---@param config sphere.SettingsConfig
---@param chartmeta sea.Chartmeta
function GameplayTimings:new(config, chartmeta)
	self.config = config
	self.chartmeta = chartmeta
end

---@param replayBase sea.ReplayBase
function GameplayTimings:apply(replayBase)
	local config = self.config
	local chartmeta = self.chartmeta

	if not config.replay_base.auto_timings then
		return
	end

	local timings = chartmeta.timings
	timings = timings or Timings(unpack(config.format_timings[chartmeta.format]))

	replayBase.timings = timings
	if chartmeta.timings then
		replayBase.timings = nil
	end

	---@type sea.Subtimings?
	local subtimings
	local subtimings_config = config.subtimings[timings.name]
	if subtimings_config then
		local name = subtimings_config[1]
		local value = subtimings_config[name]
		subtimings = Subtimings(name, value)
	end

	replayBase.subtimings = subtimings

	replayBase.timing_values = assert(TimingValuesFactory:get(timings, subtimings))
end

return GameplayTimings
