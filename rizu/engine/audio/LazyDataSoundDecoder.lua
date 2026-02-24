local LazySoundDecoder = require("rizu.engine.audio.LazySoundDecoder")

---@class rizu.LazyDataSoundDecoder: rizu.LazySoundDecoder
---@operator call: rizu.LazyDataSoundDecoder
---@field private data string
local LazyDataSoundDecoder = LazySoundDecoder + {}

---@param data string
---@param factory fun(data: string): rizu.ISoundDecoder
---@param duration number
---@param sample_rate integer
---@param channels integer
---@param bytes_per_sample integer
---@param volume number?
function LazyDataSoundDecoder:new(data, factory, duration, sample_rate, channels, bytes_per_sample, volume)
	self:init(factory, duration, sample_rate, channels, bytes_per_sample, volume)
	self.data = data
end

function LazyDataSoundDecoder:loadData()
	return self.data
end

return LazyDataSoundDecoder
