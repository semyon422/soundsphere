local class = require("class")

---@class sea.Timezone
---@operator call: sea.Timezone
local Timezone = class()

---@param h integer?
---@param m integer?
---@param negative boolean?
function Timezone:new(h, m, negative)
	self.h = h or 0
	self.m = m or 0

	if h == 0 and m == 0 then
		negative = false
	end

	self.negative = negative or false
end

function Timezone:seconds()
	return (self.h * 3600 + self.m * 60) * (self.negative and -1 or 1)
end

---@param v integer
---@return sea.Timezone
function Timezone.decode(v)
	if v == 0 then
		return Timezone()
	end

	local sign = v / math.abs(v)
	v = v * sign

	local h = math.floor(v / 100)
	local m = v % 100
	local negative = sign == -1

	return Timezone(h, m, negative)
end

---@param t sea.Timezone
---@return integer
function Timezone.encode(t)
	return (t.h * 100 + t.m) * (t.negative and -1 or 1)
end

---@return string
function Timezone:__tostring(t)
	return ("%s%02d:%02d"):format(self.negative and "-" or "+", self.h, self.m)
end

---@param a sea.Timezone
---@param b sea.Timezone
---@return boolean
function Timezone.__eq(a, b)
	return a:seconds() == b:seconds()
end

---@param a sea.Timezone
---@param b sea.Timezone
---@return boolean
function Timezone.__lt(a, b)
	return a:seconds() < b:seconds()
end

return Timezone
