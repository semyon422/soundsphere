local Point = require("ncdk2.tp.Point")

---@class ncdk2.MeasurePoint: ncdk2.Point
---@operator call: ncdk2.MeasurePoint
---@field _signature ncdk2.Signature?
---@field signature ncdk.Fraction?
---@field _tempo ncdk2.Tempo?
---@field tempo ncdk2.Tempo?
---@field _stop ncdk2.Stop?
---@field beatTime ncdk.Fraction?
local MeasurePoint = Point + {}

-- Stop should be placed on isRightSide = false
-- In this case isRightSide = true time point should be created
MeasurePoint.isRightSide = false

---@param measureTime ncdk.Fraction
---@param isRightSide boolean?
function MeasurePoint:new(measureTime, isRightSide)
	self.measureTime = measureTime
	self.isRightSide = isRightSide
end

---@param a ncdk2.MeasurePoint
---@return string
function MeasurePoint.__tostring(a)
	return ("MeasurePoint(%s,%s)"):format(a.measureTime, a.isRightSide)
end

---@return number
function MeasurePoint:getBeatModulo()
	return self.beatTime % 1
end

---@return number
function MeasurePoint:getBeatDuration()
	return self.tempo:getBeatDuration()
end

---@param a ncdk2.MeasurePoint
---@param b ncdk2.MeasurePoint
---@return boolean
function MeasurePoint.__eq(a, b)
	local at, bt = a.measureTime, b.measureTime
	return at == bt and a.isRightSide == b.isRightSide
end

---@param a ncdk2.MeasurePoint
---@param b ncdk2.MeasurePoint
---@return boolean
function MeasurePoint.__lt(a, b)
	local at, bt = a.measureTime, b.measureTime
	return at < bt or
		at == bt and a.isRightSide == false and b.isRightSide == true
end

---@param a ncdk2.MeasurePoint
---@param b ncdk2.MeasurePoint
---@return boolean
function MeasurePoint.__le(a, b)
	local at, bt = a.measureTime, b.measureTime
	return at < bt or
		at == bt and a.isRightSide == false and b.isRightSide == true or
		at == bt and a.isRightSide == b.isRightSide
end

return MeasurePoint
