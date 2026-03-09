local class = require("class")

---@class refchart.Point
---@operator call: refchart.Point
---@field time number
---@field tempo number?
---@field measure ncdk.Fraction?
local Point = class()

---@param p ncdk2.AbsolutePoint
function Point:new(p)
	self.time = p.absoluteTime
	if p._tempo then
		self.tempo = p._tempo.tempo
	end
	if p._measure then
		self.measure = p._measure.offset
	end
end

return Point
