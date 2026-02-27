local IDecoder = require("rizu.engine.audio.IDecoder")

---@class rizu.audio.fake.YieldingDecoder: rizu.audio.IDecoder
---@operator call: rizu.audio.fake.YieldingDecoder
---@field private decoder rizu.audio.IDecoder
local YieldingDecoder = IDecoder + {}

---@param decoder rizu.audio.IDecoder
function YieldingDecoder:new(decoder)
	self.decoder = decoder
end

function YieldingDecoder:getData(...)
	coroutine.yield()
	return self.decoder:getData(...)
end

function YieldingDecoder:bytesToSeconds(...)
	coroutine.yield()
	return self.decoder:bytesToSeconds(...)
end

function YieldingDecoder:secondsToBytes(...)
	coroutine.yield()
	return self.decoder:secondsToBytes(...)
end

function YieldingDecoder:getBytesPosition(...)
	coroutine.yield()
	return self.decoder:getBytesPosition(...)
end

function YieldingDecoder:setBytesPosition(...)
	coroutine.yield()
	return self.decoder:setBytesPosition(...)
end

function YieldingDecoder:getBytesDuration(...)
	coroutine.yield()
	return self.decoder:getBytesDuration(...)
end

function YieldingDecoder:getSampleRate(...)
	coroutine.yield()
	return self.decoder:getSampleRate(...)
end

function YieldingDecoder:getChannelCount(...)
	coroutine.yield()
	return self.decoder:getChannelCount(...)
end

function YieldingDecoder:getBytesPerSample(...)
	coroutine.yield()
	return self.decoder:getBytesPerSample(...)
end

function YieldingDecoder:release()
	coroutine.yield()
	self.decoder:release()
end

return YieldingDecoder
