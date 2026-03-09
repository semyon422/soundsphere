local Intervals = require("chartedit.Intervals")
local Points = require("chartedit.Points")
local Fraction = require("ncdk.Fraction")

local test = {}

function test.split_middle(t)
	local points = Points()
	points:initDefault()
	local intervals = Intervals(points)

	points:interpolateAbsolute(16, 0.25)
	local p1 = points:saveSearchPoint()

	points:interpolateAbsolute(16, 0.75)
	local p2 = points:saveSearchPoint()

	points:interpolateAbsolute(16, 0.5)
	local p = points:saveSearchPoint()

	intervals:splitInterval(p)
	t:eq(p.interval.offset, 0.5)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, 0.5)

	t:eq(p.interval.prev.offset, 0)
	t:eq(p.interval.next.offset, 1)

	t:eq(p1.interval.offset, 0)
	t:eq(p2.interval.offset, 0.5)

	intervals:mergeInterval(p)

	t:eq(p1.interval.offset, 0)
	t:eq(p2.interval.offset, 0)
end

function test.split_before(t)
	local points = Points()
	points:initDefault()
	local intervals = Intervals(points)

	points:interpolateAbsolute(16, -0.75)
	local p1 = points:saveSearchPoint()

	points:interpolateAbsolute(16, -0.25)
	local p2 = points:saveSearchPoint()

	points:interpolateAbsolute(16, -0.5)
	local p = points:saveSearchPoint()

	intervals:splitInterval(p)
	t:eq(p.interval.offset, -0.5)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, -0.5)
	t:eq(p.prev, p1)
	t:eq(p.next, p2)

	t:eq(p.interval.prev, nil)
	t:eq(p.interval.next.offset, 0)

	t:eq(p1.interval.offset, -0.5)
	t:eq(p2.interval.offset, -0.5)

	intervals:mergeInterval(p)

	t:eq(p1.interval.offset, 0)
	t:eq(p2.interval.offset, 0)
end

function test.split_after(t)
	local points = Points()
	points:initDefault()
	local intervals = Intervals(points)

	points:interpolateAbsolute(16, 1.25)
	local p1 = points:saveSearchPoint()

	points:interpolateAbsolute(16, 1.75)
	local p2 = points:saveSearchPoint()

	points:interpolateAbsolute(16, 1.5)
	local p = points:saveSearchPoint()

	intervals:splitInterval(p)
	t:eq(p.interval.offset, 1.5)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, 1.5)
	t:eq(p.prev, p1)
	t:eq(p.next, p2)

	t:eq(p.interval.prev.offset, 1)
	t:eq(p.interval.next, nil)

	t:eq(p1.interval.offset, 1)
	t:eq(p2.interval.offset, 1.5)

	intervals:mergeInterval(p)

	t:eq(p1.interval.offset, 1)
	t:eq(p2.interval.offset, 1)
end

function test.split_after_merge_before(t)
	local points = Points()
	points:initDefault()
	local intervals = Intervals(points)

	points:interpolateAbsolute(16, 0.25)
	local p25 = points:saveSearchPoint()

	points:interpolateAbsolute(16, 0.5)
	local p50 = points:saveSearchPoint()

	points:interpolateAbsolute(16, 0.75)
	local p75 = points:saveSearchPoint()

	local p0 = p25.prev
	local p100 = p75.next
	---@cast p0 -?
	---@cast p100 -?

	t:assert(p0._interval)
	t:assert(p100._interval)

	intervals:splitInterval(p50)

	t:eq(p0.interval, p0._interval)
	t:eq(p25.interval, p0._interval)
	t:eq(p50.interval, p50._interval)
	t:eq(p75.interval, p50._interval)
	t:eq(p100.interval, p100._interval)

	intervals:mergeInterval(p0)

	t:eq(p0.interval, p50._interval)
	t:eq(p25.interval, p50._interval)
	t:eq(p50.interval, p50._interval)
	t:eq(p75.interval, p50._interval)
	t:eq(p100.interval, p100._interval)

	intervals:splitInterval(p0)

	t:eq(p0.interval, p0._interval)
	t:eq(p25.interval, p0._interval)
	t:eq(p50.interval, p50._interval)
	t:eq(p75.interval, p50._interval)
	t:eq(p100.interval, p100._interval)
end

---@param t testing.T
function test.beats(t)
	local points = Points()
	points:initDefault()

	local p0 = points:getFirstPoint()
	local p10 = points:getLastPoint()
	---@cast p0 -?
	---@cast p10 -?

	points:interpolateAbsolute(16, -1.5)
	local p_15 = points:saveSearchPoint()

	points:interpolateAbsolute(16, 3.5)
	local p35 = points:saveSearchPoint()

	local intervals = Intervals(points)

	intervals:splitInterval(p_15)
	intervals:splitInterval(p35)

	t:eq(p_15._interval.beats, 2)
	t:eq(p0._interval.beats, 1)
	t:eq(p10._interval.beats, 2)
	t:eq(p35._interval.beats, 1)
end

return test
