local class = require("class")

---@class rizu.IChartAudioSource
---@operator call: rizu.IChartAudioSource
local IChartAudioSource = class()

function IChartAudioSource:release() end

function IChartAudioSource:play() end

function IChartAudioSource:pause() end

function IChartAudioSource:update() end

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

---@param size integer
function IChartAudioSource:setFFTSize(size) end

---@return any
function IChartAudioSource:getFFT() return nil end

return IChartAudioSource
