local class = require("class")

---@class ncdk2.AbsoluteCompute
---@operator call: ncdk2.AbsoluteCompute
local AbsoluteCompute = class()

---@param points ncdk2.MeasurePoint[]
---@return ncdk2.Tempo?
function AbsoluteCompute:getFirstTempo(points)
	for _, p in ipairs(points) do
		if p._tempo then
			return p._tempo
		end
	end
end

---@param points ncdk2.IntervalPoint[]
---@return ncdk2.Measure?
function AbsoluteCompute:getFirstMeasure(points)
	for _, p in ipairs(points) do
		if p._measure then
			return p._measure
		end
	end
end

---@param points ncdk2.AbsolutePoint[]
function AbsoluteCompute:compute(points)
	local tempo = self:getFirstTempo(points)
	local measure = self:getFirstMeasure(points)

	for _, point in ipairs(points) do
		local _tempo = point._tempo
		if _tempo then
			_tempo.point = point
			tempo = _tempo
		end

		if point._measure then
			measure = point._measure
		end

		point.tempo = tempo
		point.measure = measure
	end
end

return AbsoluteCompute
