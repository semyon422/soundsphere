local class = require("class")
local TimingValues = require("sea.chart.TimingValues")

---@class rizu.LogicInfo
---@operator call: rizu.LogicInfo
---@field time number
---@field rate number
---@field input_offset number
---@field timing_values sea.TimingValues
local LogicInfo = class()

function LogicInfo:new()
	self.time = 0
	self.rate = 1
	self.input_offset = 0
	self.timing_values = TimingValues()
end

---@param time number
---@return number
function LogicInfo:sub(time)
	return (self.time - time) / self.rate
end

return LogicInfo
