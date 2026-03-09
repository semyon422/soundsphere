local class = require("class")
local Fraction = require("ncdk.Fraction")

---@class ncdk2.Measure
---@operator call: ncdk2.Measure
local Measure = class()

Measure.offset = Fraction(0)

---@param offset ncdk.Fraction
function Measure:new(offset)
	self.offset = offset
end

---@param a ncdk2.Measure
---@return string
function Measure.__tostring(a)
	return ("Measure(%s)"):format(a.offset)
end

return Measure
