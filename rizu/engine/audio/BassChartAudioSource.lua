local IChartAudioSource = require("rizu.engine.audio.IChartAudioSource")
local ffi = require("ffi")
local bit = require("bit")
local bass = require("bass")
local bass_assert = require("bass.assert")
local bass_mix = require("bass.mix")
local bass_flags = require("bass.flags")

---@class rizu.BassChartAudioSource: rizu.IChartAudioSource
---@operator call: rizu.BassChartAudioSource
local BassChartAudioSource = IChartAudioSource + {}

---@param decoder rizu.ISoundDecoder
function BassChartAudioSource:new(decoder)
	self.decoder = decoder

	---@type integer
	local channel = bass.BASS_StreamCreate(decoder:getSampleRate(), decoder:getChannelCount(), 0, ffi.cast("STREAMPROC*", -1), nil)
	self.channel = channel
	bass_assert(channel ~= 0)

	local bytes_per_second = decoder:getSampleRate() * decoder:getChannelCount() * decoder:getBytesPerSample()
	self.buf_len = math.floor(bytes_per_second * 0.5)
	self.buf = ffi.new("uint8_t[?]", self.buf_len)

	ffi.gc(self.buf, function()
		self:release()
	end)

	self.pos_offset = 0
end

function BassChartAudioSource:release()
	bass_assert(bass.BASS_ChannelFree(self.channel) == 1)
	ffi.gc(self.buf, nil)
end

function BassChartAudioSource:play()
	bass_assert(bass.BASS_ChannelPlay(self.channel, false) == 1)
end

function BassChartAudioSource:pause()
	bass.BASS_ChannelPause(self.channel)
end

---@return boolean
function BassChartAudioSource:isPlaying()
	return bass_mix.BASS_Mixer_ChannelIsActive(self.channel) == bass_flags.BASS_ACTIVE_PLAYING
end

---@param rate number
function BassChartAudioSource:setRate(rate)
	bass.BASS_ChannelSetAttribute(self.channel, 1, self.decoder:getSampleRate() * rate)
end

---@return number
function BassChartAudioSource:getPosition()
	---@type integer
	local pos = bass.BASS_ChannelGetPosition(self.channel, bass_flags.BASS_POS_BYTE)
	bass_assert(pos >= 0)
	---@type number
	pos = bass.BASS_ChannelBytes2Seconds(self.channel, pos)
	bass_assert(pos >= 0)
	return pos + self.pos_offset
end

---@param pos number
function BassChartAudioSource:setPosition(pos)
	self.pos_offset = pos

	self.decoder:setPosition(pos)

	---@type integer
	local ok = bass.BASS_ChannelSetPosition(self.channel, 0, 0)
	bass_assert(ok == 1)

	self:update()
end

---@param volume number
function BassChartAudioSource:setVolume(volume)
	bass_assert(bass.BASS_ChannelSetAttribute(self.channel, bass_flags.BASS_ATTRIB_VOL, volume) == 1)
end

function BassChartAudioSource:update()
	---@type integer
	local available = bass.BASS_ChannelGetData(self.channel, nil, bass_flags.BASS_DATA_AVAILABLE)

	local need_bytes = self.buf_len - available
	if need_bytes <= 0 then
		return
	end

	ffi.fill(self.buf, need_bytes, 0)

	self.decoder:getData(self.buf, need_bytes)

	---@type integer
	local bytes = bass.BASS_StreamPutData(self.channel, self.buf, need_bytes)
	bass_assert(bytes ~= -1)
end

return BassChartAudioSource
