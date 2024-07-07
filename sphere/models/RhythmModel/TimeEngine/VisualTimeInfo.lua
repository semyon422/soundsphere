local class = require("class")

---@class sphere.VisualTimeInfo
---@operator call: sphere.VisualTimeInfo
local VisualTimeInfo = class()

---@param time number?
---@param rate number?
function VisualTimeInfo:new(time, rate)
	self.time = time or 0
	self.rate = rate or 1
end

return VisualTimeInfo
