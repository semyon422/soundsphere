local class = require("class")

---@class rizu.IAudioProvider
---@operator call: rizu.IAudioProvider
local IAudioProvider = class()

---@param data string
---@return rizu.ISoundDecoder
function IAudioProvider:createDecoder(data)
	error("not implemented")
end

---@param decoder rizu.ISoundDecoder
---@param use_tempo boolean?
---@return rizu.IChartAudioSource
function IAudioProvider:createChartSource(decoder, use_tempo)
	error("not implemented")
end

---@param use_tempo boolean?
---@return rizu.IChartAudioSource
function IAudioProvider:createMixerSource(use_tempo)
	error("not implemented")
end

return IAudioProvider
