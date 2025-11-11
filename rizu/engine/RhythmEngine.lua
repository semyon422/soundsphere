local class = require("class")
local osu_pp = require("libchart.osu_pp")
local minacalc = require("libchart.minacalc")

local ChartAudio = require("rizu.engine.audio.ChartAudio")
local BassSoundDecoder = require("rizu.engine.audio.BassSoundDecoder")
local BassChartAudioSource = require("rizu.engine.audio.BassChartAudioSource")
local ChartAudioMixer = require("rizu.engine.audio.ChartAudioMixer")
local ResourceLoader = require("rizu.files.ResourceLoader")
local ResourceFinder = require("rizu.files.ResourceFinder")
local InputEngine = require("rizu.engine.input.InputEngine")

local TimeEngine = require("rizu.engine.time.TimeEngine")

local LogicInfo = require("rizu.engine.logic.LogicInfo")
local LogicEngine = require("rizu.engine.logic.LogicEngine")

local VisualInfo = require("rizu.engine.visual.VisualInfo")
local VisualEngine = require("rizu.engine.visual.VisualEngine")

local PlayProgress = require("rizu.engine.PlayProgress")
local PauseCounter = require("rizu.engine.PauseCounter")

local ScoreEngine = require("sphere.models.RhythmModel.ScoreEngine")
local ChartplayComputed = require("sea.chart.ChartplayComputed")

---@class rizu.RhythmEngine
---@operator call: rizu.RhythmEngine
local RhythmEngine = class()

---@param fs fs.IFilesystem
function RhythmEngine:new(fs)
	self.fs = fs

	self.chart_audio = ChartAudio()

	self.resource_finder = ResourceFinder(fs)
	self.resource_loader = ResourceLoader(fs, self.resource_finder)

	self.logic_info = LogicInfo()
	self.logic_engine = LogicEngine(self.logic_info)

	self.input_engine = InputEngine(self.logic_engine.active_notes)

	self.visual_info = VisualInfo()
	self.visual_engine = VisualEngine(self.visual_info)

	self.score_engine = ScoreEngine()

	self.time_engine = TimeEngine()
	self.time_engine:setAdjustFunction(function()
		return self.chart_audio_source:getPosition()
	end)

	self.play_progress = PlayProgress()
	self.pause_counter = PauseCounter()
end

---@param chart ncdk2.Chart
---@param dir string
---@param chartmeta sea.Chartmeta
---@param chartdiff sea.Chartdiff
---@param diffcalc_context sphere.DiffcalcContext
function RhythmEngine:load(chart, dir, chartmeta, chartdiff, diffcalc_context)
	self.chart = chart
	self.chartmeta = chartmeta
	self.chartdiff = chartdiff
	self.diffcalc_context = diffcalc_context

	self.logic_engine:load(chart)
	self.visual_engine:load(chart)

	self.resource_finder:reset()
	self.resource_finder:addPath(dir)
	self.resource_loader:load(chart.resources)

	self.score_engine:load()
	self.score_engine.noteChart = chart
	self.score_engine.chartdiff = chartdiff

	self.pause_counter:new()

	local ca = ChartAudio()

	ca:load(chart, true)

	---@type rizu.BassSoundDecoder[]
	local decoders = {}
	for i, sound in ipairs(ca.sounds) do
		local data = self.resource_loader:getResource(sound.name)
		if data then
			decoders[i] = BassSoundDecoder(data)
		end
	end

	self.chart_audio_mixer = ChartAudioMixer(ca.sounds, decoders)

	local source = BassChartAudioSource(self.chart_audio_mixer)
	self.chart_audio_source = source
	self.chart_audio_source:setVolume(self.volume.master)
	self.chart_audio_source:setRate(self.logic_info.rate)

	-- local Wave = require("audio.Wave")
	-- local wave = Wave()
	-- wave:initBuffer(self.chart_audio_mixer:getChannelCount(), self.chart_audio_mixer:getSamplesDuration())
	-- self.chart_audio_mixer:getData(wave.byte_ptr, self.chart_audio_mixer:getBytesDuration())
	-- self.fs:write('audio.wav', wave:encode())

	self.visual_info.logic_notes = self.logic_engine.linked_to_logic

	local init_time = -self.time_to_prepare * self.logic_info.rate
	self:setTime(init_time)
	self.play_progress.init_time = init_time
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

---@param fast boolean?
function RhythmEngine:getChartplayComputed(fast)
	local chartdiff = self.chartdiff
	if not chartdiff then
		return ChartplayComputed()
	end

	local score_engine = self.score_engine
	local scores = score_engine.scores
	local judgesSource = assert(score_engine.judgesSource)

	-- score_engine:createByTimings(Timings("etternaj", 4))

	-- local j4 = score_engine:getScoreSystem("etterna_accuracy_j4")
	-- ---@cast j4 sphere.EtternaAccuracy

	local ns_score = scores.normalscore:getScore()
	-- print(ns_score, scores.normalscore:getScoreForWindow(0.040), j4:getAccuracyString())

	local rating_msd = 0
	if not fast then
		local ctx = self.diffcalc_context
		local ssr = minacalc.calc_ssr(ctx:getSimplifiedNotes(), ctx.chart.inputMode:getColumns(), ctx.rate, ns_score)
		rating_msd = ssr.overall
	end

	local c = ChartplayComputed()
	c.pass = not scores.hp:isFailed()
	c.judges = judgesSource:getJudges()
	c.accuracy = scores.normalscore.accuracyAdjusted
	c.max_combo = scores.base.maxCombo
	c.miss_count = scores.base.missCount
	c.not_perfect_count = judgesSource:getNotPerfect()
	c.rating = ns_score * chartdiff.enps_diff
	c.rating_pp = osu_pp.calc_no_acc(ns_score, chartdiff.osu_diff, chartdiff.notes_count)
	c.rating_msd = rating_msd

	return c
end

function RhythmEngine:unload()
	self.chart_audio_source:release()
	self.chart_audio_mixer:release()
end

function RhythmEngine:retry()
	self:setTime(0)
	self.logic_engine:load(self.chart)
	self.visual_engine:load(self.chart)
	self.pause_counter:new()
end

function RhythmEngine:update()
	self.time_engine:updateTime()

	self.logic_info.time = self.time_engine.time
	self.visual_info.time = self.time_engine.time

	self.input_engine:update()
	self.logic_engine:update()
	self.visual_engine:update()
	self.chart_audio_source:update()
end

function RhythmEngine:play()
	self.time_engine:play()
	self.chart_audio_source:play()
	self.input_engine:resume()
	self.pause_counter:play(self.time_engine.time)
end

function RhythmEngine:pause()
	self.time_engine:pause()
	self.chart_audio_source:pause()
	self.input_engine:pause()
	self.pause_counter:pause()
end

---@param event rizu.VirtualInputEvent
function RhythmEngine:receive(event)
	self.input_engine:receive(event)
end

function RhythmEngine:getProgress()
	return self.play_progress:get(self.time_engine.time)
end

---@param replay_base sea.ReplayBase
function RhythmEngine:setReplayBase(replay_base)
	self.logic_info.timing_values = replay_base.timing_values
	self.logic_info.rate = replay_base.rate

	self.input_engine.nearest = replay_base.nearest

	self.time_engine:setRate(replay_base.rate)
	self.time_engine.const = replay_base.const

	self.visual_info.const = replay_base.const
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
	self.volume = volume
end

---@param time number
function RhythmEngine:setTime(time)
	self.chart_audio_source:setPosition(time)
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
	self.time_to_prepare = time
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

---@param judgement_name string
function RhythmEngine:setScoring(judgement_name)
	self.score_engine.judgement = judgement_name
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
