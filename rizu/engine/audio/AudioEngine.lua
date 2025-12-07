local class = require("class")
local Wave = require("audio.Wave")
local ChartAudio = require("rizu.engine.audio.ChartAudio")
local BassSoundDecoder = require("rizu.engine.audio.BassSoundDecoder")
local BassChartAudioSource = require("rizu.engine.audio.BassChartAudioSource")
local IChartAudioSource = require("rizu.engine.audio.IChartAudioSource")
local ChartAudioMixer = require("rizu.engine.audio.ChartAudioMixer")

---@class rizu.AudioEngine
---@operator call: rizu.AudioEngine
---@field source rizu.IChartAudioSource
local AudioEngine = class()

AudioEngine.source = IChartAudioSource()

---@param chart ncdk2.Chart
---@param resources {[string]: string}
function AudioEngine:load(chart, resources)
	local chart_audio = ChartAudio()
	self.chart_audio = chart_audio

	chart_audio:load(chart, true)

	---@type {[integer]: rizu.BassSoundDecoder}
	local decoders = {}
	for i, sound in ipairs(chart_audio.sounds) do
		local data = resources[sound.name]
		if data then
			decoders[i] = BassSoundDecoder(data)
		end
	end

	self.mixer = ChartAudioMixer(chart_audio.sounds, decoders)
	self.source = BassChartAudioSource(self.mixer)
end

function AudioEngine:unload()
	self.source:release()
	self.source = nil
	self.mixer:release()
	self.mixer = nil
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
end

function AudioEngine:play()
	self.source:play()
end

function AudioEngine:pause()
	self.source:pause()
end

---@param rate number
function AudioEngine:setRate(rate)
	self.source:setRate(rate)
end

---@param volume number
function AudioEngine:setVolume(volume)
	self.source:setVolume(volume)
end

---@param position number
function AudioEngine:setPosition(position)
	self.source:setPosition(position)
end

return AudioEngine
