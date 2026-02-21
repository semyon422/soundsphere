local IChartAudioSource = require("rizu.engine.audio.IChartAudioSource")

---@class rizu.FakeChartAudioSource: rizu.IChartAudioSource
---@operator call: rizu.FakeChartAudioSource
local FakeChartAudioSource = IChartAudioSource + {}

function FakeChartAudioSource:new(decoder)
	self.decoder = decoder
	self.position = 0
	self.playing = false
	self.rate = 1
	self.volume = 1
end

function FakeChartAudioSource:play() self.playing = true end
function FakeChartAudioSource:pause() self.playing = false end
function FakeChartAudioSource:isPlaying() return self.playing end
function FakeChartAudioSource:getPosition() return self.position end
function FakeChartAudioSource:setPosition(pos) self.position = pos end
function FakeChartAudioSource:setRate(rate) self.rate = rate end
function FakeChartAudioSource:setVolume(vol) self.volume = vol end
function FakeChartAudioSource:update()
	if self.playing then
		self.position = self.position + 0.016 * self.rate
	end
end

return FakeChartAudioSource
