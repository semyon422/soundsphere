local ISoundDecoder = require("rizu.engine.audio.ISoundDecoder")
local bit = require("bit")
local bass = require("bass")
local bass_assert = require("bass.assert")
local bass_mix = require("bass.mix")
local bass_flags = require("bass.flags")

---@class rizu.BassSoundDecoder: rizu.ISoundDecoder
---@operator call: rizu.BassSoundDecoder
local BassSoundDecoder = ISoundDecoder + {}

BassSoundDecoder.sample_rate = 44100
BassSoundDecoder.channels_count = 2
BassSoundDecoder.bytes_per_sample = 2

---@param channel integer
---@return integer
---@return number
local function get_length(channel)
	local length = bass.BASS_ChannelGetLength(channel, 0)
	bass_assert(length >= 0)
	local duration = bass.BASS_ChannelBytes2Seconds(channel, length)
	bass_assert(length >= 0)
	return length, duration
end

---@param data string
function BassSoundDecoder:new(data)
	self.data = data

	self.decode_chan = bass.BASS_StreamCreateFile(true, data, 0, #data, bit.bor(bass_flags.BASS_STREAM_DECODE, bass_flags.BASS_STREAM_PRESCAN))
	bass_assert(self.decode_chan ~= 0)
	self.length, self.duration = get_length(self.decode_chan)

	self.resample_chan = bass_mix.BASS_Mixer_StreamCreate(self.sample_rate, self.channels_count, bass_flags.BASS_STREAM_DECODE)
	bass_assert(self.resample_chan ~= 0)

	local ok = bass_mix.BASS_Mixer_StreamAddChannel(self.resample_chan, self.decode_chan, 0)
	bass_assert(ok == 1)

	self.position = 0
	self.resample_offset = 0
end

function BassSoundDecoder:release()
	bass_assert(bass.BASS_StreamFree(self.resample_chan) == 1)
	bass_assert(bass.BASS_StreamFree(self.decode_chan) == 1)
end

---@param buf ffi.cdata*
---@param len integer
---@return integer
function BassSoundDecoder:getData(buf, len)
	local data_bytes = bass.BASS_ChannelGetData(self.resample_chan, buf, len)
	bass_assert(data_bytes ~= -1)
	self.position = self.position + data_bytes
	return data_bytes
end

---@param pos integer
---@return number
function BassSoundDecoder:bytesToSeconds(pos)
	pos = bass.BASS_ChannelBytes2Seconds(self.resample_chan, pos)
	bass_assert(pos >= 0)
	return pos
end

---@param pos number
---@return integer
function BassSoundDecoder:secondsToBytes(pos)
	pos = bass.BASS_ChannelSeconds2Bytes(self.resample_chan, pos)
	bass_assert(pos >= 0)
	return pos
end

---@return number
function BassSoundDecoder:getPosition()
	return self:bytesToSeconds(self.position)
end

---@param position number
function BassSoundDecoder:setPosition(position)
	local pos = bass.BASS_ChannelSeconds2Bytes(self.decode_chan, position)
	bass_assert(pos >= 0)
	self.position = pos
	pos = bass_mix.BASS_Mixer_ChannelSetPosition(self.decode_chan, pos, bass_flags.BASS_POS_BYTE)
	bass_assert(pos >= 0)
end

---@return number
function BassSoundDecoder:getDuration()
	return self.duration
end

return BassSoundDecoder
