local class = require("class")
local Wave = require("audio.Wave")
local ChartAudio = require("rizu.engine.audio.ChartAudio")
local BassSoundDecoder = require("rizu.engine.audio.BassSoundDecoder")
local BassChartAudioSource = require("rizu.engine.audio.BassChartAudioSource")
local IChartAudioSource = require("rizu.engine.audio.IChartAudioSource")
local ChartAudioMixer = require("rizu.engine.audio.ChartAudioMixer")
local BassMixerSource = require("rizu.engine.audio.BassMixerSource")

---@class rizu.AudioEngine
---@operator call: rizu.AudioEngine
---@field source rizu.IChartAudioSource
---@field foregroundSource rizu.IChartAudioSource
local AudioEngine = class()

AudioEngine.source = IChartAudioSource()
AudioEngine.foregroundSource = IChartAudioSource()

function AudioEngine:new()
	self.soundDataCache = {}
end

---@param chart ncdk2.Chart
---@param resources {[string]: string}
---@param auto_key_sound boolean?
function AudioEngine:load(chart, resources, auto_key_sound)
	self.resources = resources

	self.foregroundSource = BassMixerSource()

	local chart_audio = ChartAudio()
	self.chart_audio = chart_audio

	chart_audio:load(chart, auto_key_sound)

	---@type {[integer]: rizu.BassSoundDecoder}
	local decoders = {}
	for i, sound in ipairs(chart_audio.sounds) do
		local data = resources[sound.name]
		if data then
			decoders[i] = BassSoundDecoder(data)
		end
	end

	self.mixer = ChartAudioMixer(chart_audio.sounds, decoders)
	if not self.mixer.empty then
		self.source = BassChartAudioSource(self.mixer)
	end
end

---@param name string
---@param volume number?
---@param offset number?
function AudioEngine:playSample(name, volume, offset)
	local data = self.resources[name]
	if not data then
		return
	end

	local decoder = BassSoundDecoder(data)
	if offset and offset > 0 then
		decoder:setPosition(offset)
	end
	self.foregroundSource:addSound(decoder, volume)
end

function AudioEngine:unload()
	self.source:release()
	self.source = IChartAudioSource()

	if self.mixer then
		self.mixer:release()
		self.mixer = nil
	end

	self.foregroundSource:release()

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

---@param volume number
function AudioEngine:setVolume(volume)
	self.source:setVolume(volume)
	self.foregroundSource:setVolume(volume)
end

---@param position number
function AudioEngine:setPosition(position)
	self.source:setPosition(position)
	-- Hitsounds usually don't seek with the song position,
	-- but we can reset the foreground mixer if needed.
	-- Currently we just let it be.
end

return AudioEngine
