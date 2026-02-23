local ISoundDecoder = require("rizu.engine.audio.ISoundDecoder")
local Wave = require("audio.Wave")
local ffi = require("ffi")

---@class rizu.WaveSoundDecoder: rizu.ISoundDecoder
---@operator call: rizu.WaveSoundDecoder
local WaveSoundDecoder = ISoundDecoder + {}

---@param data string
function WaveSoundDecoder:new(data)
	self.wave = Wave()
	self.wave:decode(data)
	self.position = 0
end

function WaveSoundDecoder:getData(buf, len)
	local data_size = self.wave:getDataSize()
	local remaining = data_size - self.position
	local to_read = math.min(len, remaining)

	if to_read > 0 then
		ffi.copy(buf, self.wave.byte_ptr + self.position, to_read)
		self.position = self.position + to_read
	end

	return to_read
end

function WaveSoundDecoder:bytesToSeconds(pos)
	return self.wave:bytesToSeconds(pos)
end

function WaveSoundDecoder:secondsToBytes(pos)
	return self.wave:secondsToBytes(pos)
end

function WaveSoundDecoder:getBytesPosition()
	return self.position
end

function WaveSoundDecoder:setBytesPosition(pos)
	self.position = math.min(math.max(pos, 0), self.wave:getDataSize())
end

function WaveSoundDecoder:getBytesDuration()
	return self.wave:getDataSize()
end

function WaveSoundDecoder:getSampleRate()
	return self.wave.sample_rate
end

function WaveSoundDecoder:getChannelCount()
	return self.wave.channels_count
end

function WaveSoundDecoder:getBytesPerSample()
	return self.wave.bytes_per_sample
end

return WaveSoundDecoder
