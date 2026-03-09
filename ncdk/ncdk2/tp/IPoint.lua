local class = require("class")

---@class ncdk2.IPoint
---@operator call: ncdk2.IPoint
---@field absoluteTime number
local IPoint = class()

---@return number|ncdk.Fraction
function IPoint:getBeatModulo()
	return 0
end

---@return number
function IPoint:getBeatDuration()
	return 0
end

return IPoint
