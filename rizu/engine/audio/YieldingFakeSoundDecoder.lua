local ISoundDecoder = require("rizu.engine.audio.ISoundDecoder")

---@class rizu.YieldingFakeSoundDecoder: rizu.ISoundDecoder
---@field private decoder rizu.ISoundDecoder
local YieldingFakeSoundDecoder = ISoundDecoder + {}

---@param decoder rizu.ISoundDecoder
function YieldingFakeSoundDecoder:new(decoder)
	self.decoder = decoder
end

function YieldingFakeSoundDecoder:getData(...)
	coroutine.yield()
	return self.decoder:getData(...)
end

function YieldingFakeSoundDecoder:bytesToSeconds(...)
	coroutine.yield()
	return self.decoder:bytesToSeconds(...)
end

function YieldingFakeSoundDecoder:secondsToBytes(...)
	coroutine.yield()
	return self.decoder:secondsToBytes(...)
end

function YieldingFakeSoundDecoder:getBytesPosition(...)
	coroutine.yield()
	return self.decoder:getBytesPosition(...)
end

function YieldingFakeSoundDecoder:setBytesPosition(...)
	coroutine.yield()
	return self.decoder:setBytesPosition(...)
end

function YieldingFakeSoundDecoder:getBytesDuration(...)
	coroutine.yield()
	return self.decoder:getBytesDuration(...)
end

function YieldingFakeSoundDecoder:getSampleRate(...)
	coroutine.yield()
	return self.decoder:getSampleRate(...)
end

function YieldingFakeSoundDecoder:getChannelCount(...)
	coroutine.yield()
	return self.decoder:getChannelCount(...)
end

function YieldingFakeSoundDecoder:getBytesPerSample(...)
	coroutine.yield()
	return self.decoder:getBytesPerSample(...)
end

function YieldingFakeSoundDecoder:release()
	coroutine.yield()
	self.decoder:release()
end

return YieldingFakeSoundDecoder
