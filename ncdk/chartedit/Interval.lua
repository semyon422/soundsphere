local class = require("class")

---@class chartedit.Interval
---@operator call: chartedit.Interval
---@field point chartedit.Point
---@field next chartedit.Interval
---@field prev chartedit.Interval
local Interval = class()

---@param offset number
---@param beats integer
function Interval:new(offset, beats)
	self.offset = offset
	self.beats = beats
end

---@return ncdk.Fraction
function Interval:start()
	return self.point.time % 1
end

---@return number
function Interval:startn()
	return self.point.time:tonumber() % 1
end

---@return ncdk.Fraction
function Interval:_end()
	return self.next:start() + self.beats
end

---@return number
function Interval:getDuration()
	local duration = self.next:startn() - self:startn() + self.beats
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

---@return chartedit.Interval
---@return chartedit.Interval
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

---@param a chartedit.Interval
---@return string
function Interval.__tostring(a)
	return ("Interval(%s, %s)"):format(a.offset, a.beats)
end

---@param a chartedit.Interval
---@param b chartedit.Interval
---@return boolean
function Interval.__eq(a, b)
	return a.offset == b.offset
end

---@param a chartedit.Interval
---@param b chartedit.Interval
---@return boolean
function Interval.__lt(a, b)
	return a.offset < b.offset
end

---@param a chartedit.Interval
---@param b chartedit.Interval
---@return boolean
function Interval.__le(a, b)
	return a.offset <= b.offset
end

return Interval
