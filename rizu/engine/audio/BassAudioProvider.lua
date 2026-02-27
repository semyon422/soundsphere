local IAudioProvider = require("rizu.engine.audio.IAudioProvider")
local BassSoundDecoder = require("rizu.engine.audio.BassSoundDecoder")
local BassChartAudioSource = require("rizu.engine.audio.BassChartAudioSource")
local BassMixerSource = require("rizu.engine.audio.BassMixerSource")

---@class rizu.BassAudioProvider: rizu.IAudioProvider
---@operator call: rizu.BassAudioProvider
local BassAudioProvider = IAudioProvider + {}

function BassAudioProvider:createDecoder(data)
	return BassSoundDecoder(data)
end

function BassAudioProvider:createChartSource(decoder, use_tempo)
	return BassChartAudioSource(decoder, use_tempo)
end

function BassAudioProvider:createMixerSource(use_tempo)
	return BassMixerSource(use_tempo)
end

return BassAudioProvider
