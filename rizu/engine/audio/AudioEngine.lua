local class = require("class")
local Wave = require("audio.Wave")
local ChartAudio = require("rizu.engine.audio.ChartAudio")
local IChartAudioSource = require("rizu.engine.audio.IChartAudioSource")
local ChartAudioMixer = require("rizu.engine.audio.ChartAudioMixer")

---@class rizu.AudioEngine
---@operator call: rizu.AudioEngine
---@field source rizu.IChartAudioSource
---@field foregroundSource rizu.IChartAudioSource
local AudioEngine = class()

AudioEngine.DecoderClass = require("rizu.engine.audio.FakeSoundDecoder")
AudioEngine.SourceClass = require("rizu.engine.audio.FakeChartAudioSource")
AudioEngine.MixerSourceClass = require("rizu.engine.audio.FakeMixerSource")

AudioEngine.music_volume = 1
AudioEngine.keysounds_volume = 1

function AudioEngine:new()
	---@type {[string]: audio.Wave}
	self.soundDataCache = {}
	self.mode = {primary = "bass_sample", secondary = "bass_sample"}
	self.source = IChartAudioSource()
	self.foregroundSource = IChartAudioSource()
end

---@param mode {primary: string, secondary: string}
function AudioEngine:setAudioMode(mode)
	self.mode = mode
end

---@param enabled boolean
function AudioEngine:setEnabled(enabled)
	if enabled then
		self.DecoderClass = require("rizu.engine.audio.BassSoundDecoder")
		self.SourceClass = require("rizu.engine.audio.BassChartAudioSource")
		self.MixerSourceClass = require("rizu.engine.audio.BassMixerSource")
	else
		self.DecoderClass = require("rizu.engine.audio.FakeSoundDecoder")
		self.SourceClass = require("rizu.engine.audio.FakeChartAudioSource")
		self.MixerSourceClass = require("rizu.engine.audio.FakeMixerSource")
	end
end

---@param chart ncdk2.Chart
---@param resources {[string]: string}?
---@param auto_key_sound boolean?
function AudioEngine:load(chart, resources, auto_key_sound)
	self.resources = resources or {}

	local use_tempo_secondary = self.mode.secondary == "bass_fx_tempo"
	self.foregroundSource = self.MixerSourceClass(use_tempo_secondary)
	self.foregroundSource:setVolume(self.keysounds_volume)

	local chart_audio = ChartAudio()
	self.chart_audio = chart_audio

	chart_audio:load(chart, auto_key_sound)

	---@type {[integer]: rizu.ISoundDecoder}
	local decoders = {}
	for i, sound in ipairs(chart_audio.sounds) do
		local data = self.resources[sound.name]
		if data then
			decoders[i] = self.DecoderClass(data)
		end
	end

	self.mixer = ChartAudioMixer(chart_audio.sounds, decoders)
	if not self.mixer.empty then
		local use_tempo = self.mode.primary == "bass_fx_tempo"
		self.source = self.SourceClass(self.mixer, use_tempo)
		self.source:setVolume(self.music_volume)
	end
end

---@param name string
---@param volume number?
---@param offset number?
function AudioEngine:playSample(name, volume, offset)
	if not self.resources then
		return
	end
	local data = self.resources[name]
	if not data then
		return
	end

	local decoder = self.DecoderClass(data)
	if offset and offset > 0 then
		decoder:setPosition(offset)
	end
	self.foregroundSource:addSound(decoder, volume)
end

function AudioEngine:unload()
	if self.source then
		self.source:release()
		self.source = IChartAudioSource()
	end

	if self.mixer then
		self.mixer:release()
		self.mixer = nil
	end

	if self.foregroundSource then
		self.foregroundSource:release()
		self.foregroundSource = IChartAudioSource()
	end

	self.chart_audio = nil
	self.resources = nil
	self.soundDataCache = {}
end

---@return number
function AudioEngine:getStartTime()
	local chart_audio = self.chart_audio
	if not chart_audio then
		return 0
	end
	return chart_audio:getStartTime()
end

---@return audio.Wave
function AudioEngine:renderWave()
	local mixer = self.mixer
	local wave = Wave()
	wave:initBuffer(mixer:getChannelCount(), mixer:getSamplesDuration())
	mixer:getData(wave.byte_ptr, mixer:getBytesDuration())
	return wave
end

---@return number?
function AudioEngine:getPosition()
	return self.source:getPosition()
end

function AudioEngine:update()
	self.source:update()
	self.foregroundSource:update()
end

function AudioEngine:play()
	self.source:play()
	self.foregroundSource:play()
end

function AudioEngine:pause()
	self.source:pause()
	self.foregroundSource:pause()
end

---@param rate number
function AudioEngine:setRate(rate)
	self.source:setRate(rate)
	self.foregroundSource:setRate(rate)
end

---@param music_volume number
---@param keysounds_volume number
function AudioEngine:setVolume(music_volume, keysounds_volume)
	self.music_volume = music_volume
	self.keysounds_volume = keysounds_volume
	self.source:setVolume(music_volume)
	self.foregroundSource:setVolume(keysounds_volume)
end

---@param position number
function AudioEngine:setPosition(position)
	self.source:setPosition(position)
	-- Hitsounds usually don't seek with the song position,
	-- but we can reset the foreground mixer if needed.
	-- Currently we just let it be.
end

return AudioEngine
