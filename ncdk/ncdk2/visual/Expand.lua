local class = require("class")

---@class ncdk2.Expand
---@operator call: ncdk2.Expand
local Expand = class()

Expand.duration = 0

---@param duration number
function Expand:new(duration)
	self.duration = duration
end

---@param a ncdk2.Expand
---@return string
function Expand.__tostring(a)
	return ("Expand(%s)"):format(a.duration)
end

return Expand
