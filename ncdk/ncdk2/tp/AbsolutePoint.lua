local Point = require("ncdk2.tp.Point")

---@class ncdk2.AbsolutePoint: ncdk2.Point
---@operator call: ncdk2.AbsolutePoint
---@field _tempo ncdk2.Tempo?
---@field tempo ncdk2.Tempo?
---@field _measure ncdk2.Measure?
---@field measure ncdk2.Measure?
local AbsolutePoint = Point + {}

---@param a ncdk2.AbsolutePoint
---@return string
function AbsolutePoint.__tostring(a)
	return ("AbsolutePoint(%s)[%s]"):format(a.absoluteTime, a:getAbsoluteTimeKey())
end

---@return number
function AbsolutePoint:getBeatModulo()
	local tempo = self.tempo
	if not tempo then
		return 0
	end
	local measure = self.measure
	local measure_offset = measure and measure.offset or 0
	local beat_time = (self.absoluteTime - tempo.point.absoluteTime) / tempo:getBeatDuration()
	return (beat_time + measure_offset) % 1
end

---@return number
function AbsolutePoint:getBeatDuration()
	local tempo = self.tempo
	if not tempo then
		return math.huge
	end
	return tempo:getBeatDuration()
end

AbsolutePoint.__eq = Point.__eq
AbsolutePoint.__lt = Point.__lt
AbsolutePoint.__le = Point.__le

return AbsolutePoint
