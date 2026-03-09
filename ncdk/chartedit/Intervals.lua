local class = require("class")
local table_util = require("table_util")
local Interval = require("chartedit.Interval")

---@class chartedit.Intervals
---@operator call: chartedit.Intervals
local Intervals = class()

Intervals.minBeatDuration = 60 / 1000

---@param points chartedit.Points
function Intervals:new(points)
	self.points = points
end

---@param point chartedit.Point
---@param beats integer
---@return chartedit.Interval
function Intervals:_setInterval(point, beats)
	local new_ivl = Interval(point.absoluteTime, beats)
	new_ivl.point = point
	point._interval = new_ivl
	return new_ivl
end

---@param point chartedit.Point
function Intervals:splitInterval(point)
	local _interval = assert(point.interval)

	local time = point.time
	local _beats = time:floor()

	---@type chartedit.Interval
	local interval
	if time[1] > 0 then
		local beats = _interval.next and _interval.beats - _beats or 1
		interval = self:_setInterval(point, beats)
		table_util.insert_linked(interval, _interval, _interval.next)
		_interval.beats = _beats
	else
		interval = self:_setInterval(point, -_beats)
		table_util.insert_linked(interval, nil, _interval)
		point = self.points:getFirstPoint()
	end
	while point and point.interval == _interval and point._interval ~= _interval do
		point.interval = interval
		point.time = point.time - _beats
		point = point.next
	end
end

---@param point chartedit.Point
function Intervals:mergeInterval(point)
	local _interval = point._interval
	if not _interval then
	-- if not _interval or self.ranges.interval.tree.size == 2 then
		return
	end

	point._interval = nil
	local _prev, _next = table_util.remove_linked(_interval)

	local _beats, interval
	if _prev then
		_beats = _prev.beats
		_prev.beats = _next and _prev.beats + _interval.beats or 1
		interval = _prev
	elseif _next then
		_beats = -_interval.beats
		point = self.points:getFirstPoint()
		interval = _next
	end

	while point and point.interval == _interval do
		point.interval = interval
		point.time = point.time + _beats
		point = point.next
	end
end

---@param interval chartedit.Interval
---@param offset number
function Intervals:moveInterval(interval, offset)
	if interval.offset == offset then
		return
	end
	local minTime, maxTime = -math.huge, math.huge
	if interval.prev then
		minTime = interval.prev.offset + self.minBeatDuration * interval.prev:getDuration()
	end
	if interval.next then
		maxTime = interval.next.offset - self.minBeatDuration * interval:getDuration()
	end
	if minTime >= maxTime then
		return
	end
	interval.offset = math.min(math.max(offset, minTime), maxTime)
end

---@param interval chartedit.Interval
---@param beats number
function Intervals:updateInterval(interval, beats)
	local a, b = interval, interval.next
	if not b then
		return
	end

	assert(math.floor(beats) == beats)
	beats = math.max(beats, a:start() >= b:start() and 1 or 0)

	if beats == a.beats then
		return
	end

	local _a, _b = a.point, b.point

	local maxBeats = (_b.absoluteTime - _a.absoluteTime) / self.minBeatDuration + a:start() - b:start()
	beats = math.min(beats, math.floor(maxBeats))

	if beats < interval.beats then
		local p = b.point.prev
		while p and p ~= _a and p.time >= b:start() + beats do
			self.points:removePoint(p)
			p = p.prev
		end
	end
	interval.beats = beats
end

return Intervals
