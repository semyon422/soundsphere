local class = require("class")
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

	self.time_engine = TimeEngine(0.5, function()
		return self.chart_audio_source:getPosition()
	end)
end

---@param chart ncdk2.Chart
---@param dir string
function RhythmEngine:load(chart, dir)
	self.logic_engine:load(chart)
	self.visual_engine:load(chart)

	self.resource_finder:reset()
	self.resource_finder:addPath(dir)
	self.resource_loader:load(chart.resources)

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
	self.chart_audio_mixer:setPosition(0)

	local source = BassChartAudioSource(self.chart_audio_mixer)
	self.chart_audio_source = source
	self.chart_audio_source:setVolume(self.volume.master)

	-- local Wave = require("audio.Wave")
	-- local wave = Wave()
	-- wave:initBuffer(self.chart_audio_mixer:getChannelCount(), self.chart_audio_mixer:getSamplesDuration())
	-- self.chart_audio_mixer:getData(wave.byte_ptr, self.chart_audio_mixer:getBytesDuration())
	-- self.fs:write('audio.wav', wave:encode())

	self.visual_info.logic_notes = self.logic_engine.linked_to_logic
end

function RhythmEngine:unload()
	self.chart_audio_source:release()
	self.chart_audio_mixer:release()
end

function RhythmEngine:update()
	-- self.time_engine:setGlobalTime(0)

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
end

function RhythmEngine:pause()
	self.time_engine:pause()
	self.chart_audio_source:pause()
	self.input_engine:pause()
end

---@param event rizu.VirtualInputEvent
function RhythmEngine:receive(event)
	self.input_engine:receive(event)
end

---@param replay_base sea.ReplayBase
function RhythmEngine:setReplayBase(replay_base)
	local logic_info = self.logic_info

	logic_info.timing_values = replay_base.timing_values

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

---@param volume {master: number, music: number, effects: number}
function RhythmEngine:setVolume(volume)
	self.volume = volume
end

return RhythmEngine
