local class = require("class")

---@class sphere.IAccuracySource
---@operator call: sphere.IAccuracySource
local IAccuracySource = class()

IAccuracySource.accuracy_multiplier = 1

---@return number
function IAccuracySource:getAccuracy()
	error("not implemented")
end

---@return string
function IAccuracySource:getAccuracyString()
	return tostring(self:getAccuracy())
end

return IAccuracySource
