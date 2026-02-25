local class = require("class")

---@class rizu.RhythmEngineLoader
---@operator call: rizu.RhythmEngineLoader
local RhythmEngineLoader = class()

---@param replayBase sea.ReplayBase
---@param computeContext sea.ComputeContext
---@param config sphere.SettingsConfig
---@param resources {[string]: string}
function RhythmEngineLoader:new(replayBase, computeContext, config, resources)
	self.replayBase = replayBase
	self.computeContext = computeContext
	self.config = config
	self.resources = resources
end

---@param enabled boolean
function RhythmEngineLoader:setAudioEnabled(enabled)
	self.audioEnabled = enabled
end

---@param rhythm_engine rizu.RhythmEngine
function RhythmEngineLoader:load(rhythm_engine)
	local computeContext = self.computeContext
	local replayBase = self.replayBase
	local config = self.config

	local chart = assert(computeContext.chart)
	local chartmeta = assert(computeContext.chartmeta)
	local chartdiff = assert(computeContext.chartdiff)
	local state = computeContext.state

	rhythm_engine:setChart(chart, chartmeta, chartdiff)
	rhythm_engine:setAutoKeySound(config.gameplay.autoKeySound)
	rhythm_engine:setAudioEnabled(self.audioEnabled)
	rhythm_engine:load()
	rhythm_engine:setAudioMode(config.audio.mode)
	rhythm_engine:loadAudio(self.resources)

	-- variable unranked
	-- rhythm_engine:setWindUp(state.windUp)
	rhythm_engine:setTimings(replayBase.timings, replayBase.subtimings)
	rhythm_engine:setTimingValues(replayBase.timing_values)
	rhythm_engine:setRate(replayBase.rate)
	rhythm_engine:setNearest(replayBase.nearest)
	rhythm_engine:setConst(replayBase.const)

	-- constant
	rhythm_engine:setPlayTime(chartdiff.start_time, chartdiff.duration)
	rhythm_engine:setTimeToPrepare(config.gameplay.time.prepare)

	-- variable ranked
	rhythm_engine:setAdjustFactor(config.audio.adjustRate)

	local volume = {
		master = config.audio.volume.master,
		music = config.audio.volume.music,
		keysounds = config.audio.volume.keysounds * (config.audio.volume.keysounds_format[chartmeta.format] or 1),
	}
	rhythm_engine:setVolume(volume)

	rhythm_engine:setLongNoteShortening(config.gameplay.longNoteShortening)
	rhythm_engine:setVisualRate(config.gameplay.speed, config.gameplay.scaleSpeed)
end

return RhythmEngineLoader
