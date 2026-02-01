local class = require("class")

local InputEngine = require("rizu.engine.input.InputEngine")
local ActiveInputNotes = require("rizu.engine.input.ActiveInputNotes")

local AudioEngine = require("rizu.engine.audio.AudioEngine")
local TimeEngine = require("rizu.engine.time.TimeEngine")

local LogicInfo = require("rizu.engine.logic.LogicInfo")
local LogicEngine = require("rizu.engine.logic.LogicEngine")

local VisualInfo = require("rizu.engine.visual.VisualInfo")
local VisualEngine = require("rizu.engine.visual.VisualEngine")

local PlayProgress = require("rizu.engine.PlayProgress")
local PauseCounter = require("rizu.engine.PauseCounter")

local ScoreEngine = require("sphere.models.RhythmModel.ScoreEngine")

---@class rizu.RhythmEngine
---@operator call: rizu.RhythmEngine
local RhythmEngine = class()

function RhythmEngine:new()
	self.logic_info = LogicInfo()

	self.logic_engine = LogicEngine(self.logic_info)

	self.active_input_notes = ActiveInputNotes(self.logic_engine.active_notes)
	self.input_engine = InputEngine(self.active_input_notes)

	self.visual_info = VisualInfo()
	self.visual_engine = VisualEngine(self.visual_info)

	self.score_engine = ScoreEngine()
	function self.logic_info.on_note_change(change)
		self.score_engine:receive(change)
	end

	self.audio_engine = AudioEngine()

	self.time_engine = TimeEngine()
	self.time_engine:setAdjustFunction(function()
		return self.audio_engine:getPosition()
	end)

	self.play_progress = PlayProgress()
	self.pause_counter = PauseCounter()
end

function RhythmEngine:load()
	local chart = self.chart

	self.active_input_notes:setInputMap(chart.inputMode:getInputMap())
	self.logic_engine:load(chart)
	self.visual_engine:load(chart)
	self.score_engine:load(self.chartdiff)
	self.pause_counter:new()

	self.visual_info.logic_notes = self.logic_engine.linked_to_logic
end

---@param resources {[string]: string}
function RhythmEngine:loadAudio(resources)
	self.audio_engine:load(self.chart, resources)
end

---@return boolean
function RhythmEngine:hasResult()
	local logic_engine = self.logic_engine
	local time_engine = self.time_engine
	local base = self.score_engine.scores.base
	local accuracy = self.score_engine.scores.normalscore.accuracyAdjusted

	return
		not logic_engine.autoplay and
		not logic_engine.promode and
		not time_engine.wind_up and
		time_engine.time >= self.play_progress.start_time and
		base.hitCount > 0 and
		accuracy > 0 and
		accuracy < math.huge
end

function RhythmEngine:unload()
	self.audio_engine:unload()
end

function RhythmEngine:retry()
	self:setTime(0)
	self.logic_engine:load(self.chart)
	self.visual_engine:load(self.chart)
	self.pause_counter:new()
end

function RhythmEngine:update()
	self.logic_info.time = self.time_engine.time
	self.visual_info.time = self.time_engine.time

	self.input_engine:update()
	self.logic_engine:update()
	self.visual_engine:update()
	self.audio_engine:update()
end

function RhythmEngine:play()
	self.time_engine:play()
	self.audio_engine:play()
	self.input_engine:resume()
	self.pause_counter:play(self.time_engine.time)
end

function RhythmEngine:pause()
	self.time_engine:pause()
	self.audio_engine:pause()
	self.input_engine:pause()
	self.pause_counter:pause()
end

---@param event rizu.VirtualInputEvent
function RhythmEngine:receive(event)
	self.input_engine:receive(event)
end

function RhythmEngine:getTime()
	return self.time_engine.time
end

function RhythmEngine:getProgress()
	return self.play_progress:get(self:getTime())
end

---@param chart ncdk2.Chart
---@param chartmeta sea.Chartmeta
---@param chartdiff sea.Chartdiff
function RhythmEngine:setChart(chart, chartmeta, chartdiff)
	self.chart = chart
	self.chartmeta = chartmeta
	self.chartdiff = chartdiff
end

---@param timings sea.Timings?
---@param subtimings sea.Subtimings?
function RhythmEngine:setTimings(timings, subtimings)
	timings = assert(timings or self.chartmeta.timings)
	self.score_engine:createByTimings(timings, subtimings, true)
end

---@param timing_values sea.TimingValues
function RhythmEngine:setTimingValues(timing_values)
	self.logic_info.timing_values = timing_values
end

---@param rate number
function RhythmEngine:setRate(rate)
	self.logic_info.rate = rate
	self.time_engine:setRate(rate)
	self.audio_engine:setRate(rate)
end

---@param nearest boolean
function RhythmEngine:setNearest(nearest)
	self.input_engine.nearest = nearest
end

---@param const boolean
function RhythmEngine:setConst(const)
	self.time_engine.const = const
	self.visual_info.const = const
end

---@param time number
function RhythmEngine:setGlobalTime(time)
	self.time_engine:setGlobalTime(time)
end

---@param adjust_factor number
function RhythmEngine:setAdjustFactor(adjust_factor)
	self.time_engine:setAdjustFactor(adjust_factor)
end

---@param visual_rate number
---@param scale_visual_rate boolean?
function RhythmEngine:setVisualRate(visual_rate, scale_visual_rate)
	if not scale_visual_rate then
		visual_rate = visual_rate / self.logic_info.rate
	end
	self.visual_info.rate = visual_rate
end

---@param volume {master: number, music: number, effects: number}
function RhythmEngine:setVolume(volume)
	self.audio_engine:setVolume(volume.master)
end

---@param time number
function RhythmEngine:setTime(time)
	self.audio_engine:setPosition(time)
	self.time_engine:setTime(time)
	self:update()
end

---@param offset number
function RhythmEngine:setInputOffset(offset)
	self.logic_info.offset = offset
end

---@param offset number
function RhythmEngine:setVisualOffset(offset)
	self.visual_info.offset = offset
end

---@param shortening number
function RhythmEngine:setLongNoteShortening(shortening)
	self.visual_info.shortening = shortening
end

---@param time number
function RhythmEngine:setTimeToPrepare(time)
	local start_time = self.play_progress.start_time
	local time_to_prepare = math.min(start_time - time, self.audio_engine:getStartTime())
	local init_time = time_to_prepare * self.logic_info.rate
	self:setTime(init_time)
	self.play_progress.init_time = init_time
end

---@param start_time number
---@param duration number
function RhythmEngine:setPlayTime(start_time, duration)
	self.play_progress.start_time = start_time
	self.play_progress.duration = duration
	self.pause_counter:setPlayTime(start_time, duration)
end

---@param audio_mode {primary: string, secondary: string}
function RhythmEngine:setAudioMode(audio_mode)
	self.audio_mode = audio_mode
end

---@param wind_up string
function RhythmEngine:setWindUp(wind_up)
end

---@param autoplay boolean
function RhythmEngine:setAutoplay(autoplay)
end

---@param pro_mode boolean
function RhythmEngine:setProMode(pro_mode)
end

return RhythmEngine
