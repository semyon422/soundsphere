local class = require("class")

---@class rizu.TimeInfo
---@operator call: rizu.TimeInfo
local TimeInfo = class()

---@param time number
---@param rate number
function TimeInfo:new(time, rate)
	self.time = time
	self.rate = rate
end

function TimeInfo:setTime(time)
	self.time = time
end

---@param time number
---@return number
function TimeInfo:sub(time)
	return (self.time - time) / self.rate
end

return TimeInfo
