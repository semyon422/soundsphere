local class = require("class")

---@class ncdk2.IntervalCompute
---@operator call: ncdk2.IntervalCompute
local IntervalCompute = class()

---@param points ncdk2.IntervalPoint[]
---@return ncdk2.Measure?
function IntervalCompute:getFirstMeasure(points)
	for _, p in ipairs(points) do
		if p._measure then
			return p._measure
		end
	end
end

---@param points ncdk2.IntervalPoint[]
function IntervalCompute:compute(points)
	local measure = self:getFirstMeasure(points)

	---@type ncdk2.Interval[]
	local intervals = {}
	for _, p in ipairs(points) do
		if p._interval then
			table.insert(intervals, p._interval)
			p._interval.point = p
		end
	end

	for i = 1, #intervals - 1 do
		local interval = intervals[i]
		local next_interval = intervals[i + 1]
		interval.next, next_interval.prev = next_interval, interval
	end

	local interval = intervals[1]
	for _, point in ipairs(points) do
		if point._measure then
			measure = point._measure
		end

		local _interval = point._interval
		if _interval then
			interval = _interval
		end

		point.interval = interval
		point.measure = measure
	end

	for _, point in ipairs(points) do
		point.absoluteTime = point:tonumber()
	end
end

return IntervalCompute
