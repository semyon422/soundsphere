local ISoundDecoder = require("rizu.engine.audio.ISoundDecoder")
local Wave = require("audio.Wave")
local ffi = require("ffi")

---@class rizu.SoundDecoder: rizu.ISoundDecoder
---@operator call: rizu.SoundDecoder
local FakeSoundDecoder = ISoundDecoder + {}

---@param samples_count integer
---@param sample_rate integer?
---@param channels_count integer?
function FakeSoundDecoder:new(samples_count, sample_rate, channels_count)
	local wave = Wave()
	self.wave = wave

	wave.sample_rate = sample_rate or wave.sample_rate
	wave:initBuffer(channels_count or 2, assert(samples_count))

	self.position = 0
end

---@param buf ffi.cdata*
---@param len integer
---@return integer
function FakeSoundDecoder:getData(buf, len)
	local wave = self.wave
	len = wave:floorBytes(len)

	local bytes = math.min(wave:getDataSize() - self.position, len)
	if bytes == 0 then
		return 0
	end

	ffi.copy(buf, wave.byte_ptr + self.position, bytes)
	self.position = self.position + bytes

	return bytes
end

---@param pos integer
---@return number
function FakeSoundDecoder:bytesToSeconds(pos)
	return self.wave:bytesToSeconds(pos)
end

---@param pos number
---@return integer
function FakeSoundDecoder:secondsToBytes(pos)
	return self.wave:secondsToBytes(pos)
end

---@return integer
function FakeSoundDecoder:getBytesPosition()
	return self.position
end

---@param pos integer
function FakeSoundDecoder:setBytesPosition(pos)
	self.position = pos
end

---@return integer
function FakeSoundDecoder:getBytesDuration()
	return self.wave:getDataSize()
end

---@return integer
function FakeSoundDecoder:getSampleRate()
	return self.wave.sample_rate
end

---@return integer
function FakeSoundDecoder:getChannelCount()
	return self.wave.channels_count
end

---@return integer
function FakeSoundDecoder:getBytesPerSample()
	return self.wave.bytes_per_sample
end

return FakeSoundDecoder
