local class = require("class")

---@class rizu.LocalTimer
---@operator call: rizu.LocalTimer
local LocalTimer = class()

LocalTimer.is_playing = false
LocalTimer.offset = 0
LocalTimer.rate = 1
LocalTimer.adjustRate = 0.1

---@return number
function LocalTimer:getGlobalTime()
	return 0
end

---@return number?
function LocalTimer:getAdjustTime() end

---@return number?
function LocalTimer:tryAdjust()
	local adjustTime = self:getAdjustTime()
	if not adjustTime then
		return
	end
	if adjustTime == self.prevAdjustTime then
		return
	end
	self.prevAdjustTime = adjustTime
	return adjustTime
end

function LocalTimer:adjust()
	local time = self:getTime()

	local adjustTime = self:tryAdjust()
	if adjustTime and self.adjustRate > 0 then
		time = time + (adjustTime - time) * self.adjustRate
		self:setTime(time)
	end
end

---@return number
function LocalTimer:getDeltaGlobalTime()
	if not self.is_playing then
		return 0
	end
	return self:getGlobalTime() - self.global_offset
end

---@return number
function LocalTimer:getTime()
	local dt = self:getDeltaGlobalTime()
	return dt * self.rate + self.offset
end

---@param global_time number
---@return number
function LocalTimer:transform(global_time)
	return (global_time - self:getGlobalTime()) * self.rate + self:getTime()
end

---@param time number?
function LocalTimer:setTime(time)
	self.offset = time or self:getTime()
	self.global_offset = self:getGlobalTime()
end

---@param rate number
function LocalTimer:setRate(rate)
	self:setTime()
	self.rate = rate
end

function LocalTimer:pause()
	if not self.is_playing then
		return
	end

	self:setTime()
	self.is_playing = false
end

function LocalTimer:play()
	if self.is_playing then
		return
	end

	self:setTime()
	self.is_playing = true
end

return LocalTimer
