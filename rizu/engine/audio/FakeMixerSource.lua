local IChartAudioSource = require("rizu.engine.audio.IChartAudioSource")

---@class rizu.FakeMixerSource: rizu.IChartAudioSource
---@operator call: rizu.FakeMixerSource
local FakeMixerSource = IChartAudioSource + {}

function FakeMixerSource:new()
	self.active_sounds = {}
	self.volume = 1
	self.rate = 1
end

function FakeMixerSource:addSound(decoder, volume)
	table.insert(self.active_sounds, {
		decoder = decoder,
		volume = volume or 1,
	})
end

function FakeMixerSource:setVolume(vol) self.volume = vol end
function FakeMixerSource:setRate(rate) self.rate = rate end
function FakeMixerSource:update() end
function FakeMixerSource:play() end
function FakeMixerSource:pause() end

return FakeMixerSource
