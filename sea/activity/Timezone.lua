local class = require("class")

---@class sea.Timezone
---@operator call: sea.Timezone
local Timezone = class()

---@param h integer
---@param m integer
---@param negative boolean?
function Timezone:new(h, m, negative)
	self.h = h
	self.m = m
	self.negative = negative or false
end

function Timezone:seconds()
	return (self.h * 3600 + self.m * 60) * (self.negative and -1 or 1)
end

return Timezone
