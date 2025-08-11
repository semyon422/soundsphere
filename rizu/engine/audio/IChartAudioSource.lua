local class = require("class")

---@class rizu.IChartAudioSource
---@operator call: rizu.IChartAudioSource
local IChartAudioSource = class()

---@param sounds rizu.ChartAudioSound[]
---@param resources {[string]: audio.SoundData}
function IChartAudioSource:new(sounds, resources)
	self.sounds = sounds
	self.resources = resources
end

function IChartAudioSource:play() end
function IChartAudioSource:pause() end

---@return boolean
function IChartAudioSource:isPlaying() return false end

---@param rate number
function IChartAudioSource:setRate(rate) end

---@return number
function IChartAudioSource:getPosition() return 0 end

---@param position number
function IChartAudioSource:setPosition(position) end

---@return number
function IChartAudioSource:getStartTime() return 0 end

---@return number
function IChartAudioSource:getDuration() return 0 end

---@param volume number
function IChartAudioSource:setVolume(volume) end

return IChartAudioSource
