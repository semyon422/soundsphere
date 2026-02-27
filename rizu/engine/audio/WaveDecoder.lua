local IDecoder = require("rizu.engine.audio.IDecoder")
local Wave = require("audio.Wave")
local ffi = require("ffi")

---@class rizu.audio.WaveDecoder: rizu.audio.IDecoder
---@operator call: rizu.audio.WaveDecoder
local WaveDecoder = IDecoder + {}

---@param data string
function WaveDecoder:new(data)
	self.wave = Wave()
	self.wave:decode(data)
	self.position = 0
end

function WaveDecoder:getData(buf, len)
	local data_size = self.wave:getDataSize()
	local remaining = data_size - self.position
	local to_read = math.min(len, remaining)

	if to_read > 0 then
		ffi.copy(buf, self.wave.byte_ptr + self.position, to_read)
		self.position = self.position + to_read
	end

	return to_read
end

function WaveDecoder:bytesToSeconds(pos)
	return self.wave:bytesToSeconds(pos)
end

function WaveDecoder:secondsToBytes(pos)
	return self.wave:secondsToBytes(pos)
end

function WaveDecoder:getBytesPosition()
	return self.position
end

function WaveDecoder:setBytesPosition(pos)
	self.position = math.min(math.max(pos, 0), self.wave:getDataSize())
end

function WaveDecoder:getBytesDuration()
	return self.wave:getDataSize()
end

function WaveDecoder:getSampleRate()
	return self.wave.sample_rate
end

function WaveDecoder:getChannelCount()
	return self.wave.channels_count
end

function WaveDecoder:getBytesPerSample()
	return self.wave.bytes_per_sample
end

return WaveDecoder
