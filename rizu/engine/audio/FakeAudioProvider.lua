local IAudioProvider = require("rizu.engine.audio.IAudioProvider")
local FakeSoundDecoder = require("rizu.engine.audio.FakeSoundDecoder")
local FakeChartAudioSource = require("rizu.engine.audio.FakeChartAudioSource")
local FakeMixerSource = require("rizu.engine.audio.FakeMixerSource")

---@class rizu.FakeAudioProvider: rizu.IAudioProvider
---@operator call: rizu.FakeAudioProvider
local FakeAudioProvider = IAudioProvider + {}

function FakeAudioProvider:createDecoder(data)
	-- Use a small amount of samples as placeholder if data is a string
	local count = type(data) == "string" and #data or 100
	return FakeSoundDecoder(count)
end

function FakeAudioProvider:createChartSource(decoder, use_tempo)
	return FakeChartAudioSource(decoder)
end

function FakeAudioProvider:createMixerSource(use_tempo)
	return FakeMixerSource()
end

return FakeAudioProvider
