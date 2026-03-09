local class = require("class")

---@class ncdk2.Stop
---@operator call: ncdk2.Stop
local Stop = class()

---@param duration number|ncdk.Fraction
---@param isAbsolute boolean?
function Stop:new(duration, isAbsolute)
	self.duration = duration
	self.isAbsolute = isAbsolute
end

---@param a ncdk2.Stop
---@return string
function Stop.__tostring(a)
	return ("Stop(%s)"):format(a.duration)
end

return Stop
