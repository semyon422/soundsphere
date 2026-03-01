local IDecoder = require("rizu.engine.audio.IDecoder")
local ffi = require("ffi")

---@class rizu.audio.LazyDecoder: rizu.audio.IDecoder
---@field private fs fs.IFilesystem
---@field private path string
---@field private factory fun(data: string): rizu.audio.IDecoder
---@field private duration number
---@field private sample_rate integer
---@field private channels integer
---@field private bytes_per_sample integer
---@field private volume number
---@field private real_decoder rizu.audio.IDecoder?
---@field private bytes_position integer
local LazyDecoder = IDecoder + {}

---@param fs fs.IFilesystem
---@param path string
---@param factory fun(data: string): rizu.audio.IDecoder
---@param duration number
---@param sample_rate integer
---@param channels integer
---@param bytes_per_sample integer
---@param volume number?
function LazyDecoder:new(fs, path, factory, duration, sample_rate, channels, bytes_per_sample, volume)
	self:init(factory, duration, sample_rate, channels, bytes_per_sample, volume)
	self.fs = fs
	self.path = path
end

---@param factory fun(data: string): rizu.audio.IDecoder
---@param duration number
---@param sample_rate integer
---@param channels integer
---@param bytes_per_sample integer
---@param volume number?
function LazyDecoder:init(factory, duration, sample_rate, channels, bytes_per_sample, volume)
	self.factory = factory
	self.duration = duration
	self.sample_rate = sample_rate
	self.channels = channels
	self.bytes_per_sample = bytes_per_sample
	self.volume = volume or 1
	self.real_decoder = nil
	self.bytes_position = 0
end

---@protected
---@return string
function LazyDecoder:loadData()
	return self.fs:read(self.path) or ""
end

---@private
---@return rizu.audio.IDecoder
function LazyDecoder:ensureLoaded()
	if not self.real_decoder then
		local data = self:loadData()
		self.real_decoder = self.factory(data)
		if self.bytes_position ~= 0 then
			self.real_decoder:setBytesPosition(self.bytes_position)
		end
	end
	return self.real_decoder
end

function LazyDecoder:getData(buf, len)
	local dec = self:ensureLoaded()
	local bytes = dec:getData(buf, len)

	if self.volume ~= 1 and bytes > 0 then
		local samples = bytes / self.bytes_per_sample
		---@type {[integer]: integer}
		local ptr = ffi.cast("int16_t*", buf)
		local vol = self.volume
		for i = 0, samples - 1 do
			local val = math.floor(ptr[i] * vol + 0.5)
			if val > 32767 then
				val = 32767
			elseif val < -32768 then
				val = -32768
			end
			ptr[i] = val
		end
	end

	return bytes
end

function LazyDecoder:getSampleRate() return self.sample_rate end
function LazyDecoder:getChannelCount() return self.channels end
function LazyDecoder:getBytesPerSample() return self.bytes_per_sample end
function LazyDecoder:getDuration() return self.duration end

function LazyDecoder:getBytesDuration()
	return math.floor(self.duration * self.sample_rate) * self.channels * self.bytes_per_sample
end

function LazyDecoder:getBytesPosition()
	if self.real_decoder then
		return self.real_decoder:getBytesPosition()
	end
	return self.bytes_position
end

function LazyDecoder:setBytesPosition(pos)
	if self.real_decoder then
		self.real_decoder:setBytesPosition(pos)
	else
		self.bytes_position = pos
	end
end

function LazyDecoder:secondsToBytes(s)
	return math.floor(s * self.sample_rate) * self.channels * self.bytes_per_sample
end

function LazyDecoder:bytesToSeconds(b)
	return b / (self.sample_rate * self.channels * self.bytes_per_sample)
end

function LazyDecoder:release()
	if self.real_decoder then
		self.real_decoder:release()
		self.real_decoder = nil
	end
end

return LazyDecoder
