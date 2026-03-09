local class = require("class")

---@class ncdk2.Interval
---@operator call: ncdk2.Interval
---@field point ncdk2.IntervalPoint
---@field next ncdk2.Interval?
---@field prev ncdk2.Interval?
local Interval = class()

---@param offset number
function Interval:new(offset)
	self.offset = offset
end

---@return ncdk.Fraction
function Interval:time()
	return self.point.time
end

---@return number
function Interval:getDuration()
	local duration = (self.next:time() - self:time()):tonumber()
	if duration <= 0 then
		error("zero interval duration found: " .. tostring(self) .. ", " .. tostring(self.next))
	end
	return duration
end

---@return number
function Interval:getBeatDuration()
	local a, b = self:getPair()
	return (b.offset - a.offset) / a:getDuration()
end

---@return number
function Interval:getTempo()
	return 60 / self:getBeatDuration()
end

---@return ncdk2.Interval
---@return ncdk2.Interval
---@return boolean
function Interval:getPair()
	local a = self
	local n = a.next
	if n then
		return a, n, false
	end
	return a.prev, a, true
end

---@return boolean
function Interval:isSingle()
	return not self.prev and not self.next
end

---@param a ncdk2.Interval
---@return string
function Interval.__tostring(a)
	return ("Interval(%s)"):format(a.offset)
end

return Interval
