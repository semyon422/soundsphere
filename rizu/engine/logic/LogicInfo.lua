local class = require("class")
local TimingValues = require("sea.chart.TimingValues")

---@class rizu.LogicInfo
---@operator call: rizu.LogicInfo
---@field time number
---@field rate number
---@field offset number
---@field timing_values sea.TimingValues
local LogicInfo = class()

function LogicInfo:new()
	self.time = 0
	self.rate = 1
	self.offset = 0
	self.timing_values = TimingValues()
end

---@return number
function LogicInfo:getTime()
	return self.time - self.offset
end

---@param time number
---@return number
function LogicInfo:sub(time)
	return (self:getTime() - time) / self.rate
end

---@param key sea.TimingObjectKey
---@return number
function LogicInfo:getNoteMinTime(key)
	return self.timing_values:getMinTime(key) * self.rate
end

---@param key sea.TimingObjectKey
---@return number
function LogicInfo:getNoteMaxTime(key)
	return self.timing_values:getMaxTime(key) * self.rate
end

return LogicInfo
