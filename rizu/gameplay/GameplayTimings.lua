local class = require("class")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")

---@class rizu.GameplayTimings
---@operator call: rizu.GameplayTimings
local GameplayTimings = class()

---@param config sphere.SettingsConfig
---@param replayBase sea.ReplayBase
---@param chartmeta sea.Chartmeta
function GameplayTimings:new(
	config,
	replayBase,
	chartmeta
)
	self.config = config
	self.replayBase = replayBase
	self.chartmeta = chartmeta
end

function GameplayTimings:load()
	local config = self.config
	if config.replay_base.auto_timings then
		self:actualizeReplayBaseTimings()
	end
end

---@param timings sea.Timings
function GameplayTimings:setReplayBaseTimings(timings)
	local replayBase = self.replayBase

	---@type sea.Subtimings?
	local subtimings
	local subtimings_config = self.config.subtimings[timings.name]
	if subtimings_config then
		local name = subtimings_config[1]
		local value = subtimings_config[name]
		subtimings = Subtimings(name, value)
	end

	replayBase.timings = timings
	replayBase.subtimings = subtimings
	replayBase.timing_values = assert(TimingValuesFactory:get(timings, subtimings))
end

function GameplayTimings:actualizeReplayBaseTimings()
	local chartmeta = self.chartmeta

	local timings = chartmeta.timings
	timings = timings or Timings(unpack(self.config.format_timings[chartmeta.format]))
	self:setReplayBaseTimings(timings)

	if chartmeta.timings then
		self.replayBase.timings = nil
	end
end

return GameplayTimings
