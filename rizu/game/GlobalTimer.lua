local class = require("class")

---@class rizu.GlobalTimer
---@operator call: rizu.GlobalTimer
local GlobalTimer = class()

GlobalTimer.time = 0

---@param time number
function GlobalTimer:setTime(time)
	self.time = time
end

---@return number
function GlobalTimer:getTime()
	return self.time
end

return GlobalTimer
