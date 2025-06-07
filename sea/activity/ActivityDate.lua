local class = require("class")

---@class sea.ActivityDate
---@operator call: sea.ActivityDate
---@field year integer
---@field month integer
---@field day integer
local ActivityDate = class()

---@param y integer
---@param m integer
---@param d integer
function ActivityDate:new(y, m, d)
	self.year = y
	self.month = m
	self.day = d
end

return ActivityDate
