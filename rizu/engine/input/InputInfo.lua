local class = require("class")
local TimingValues = require("sea.chart.TimingValues")

---@class rizu.InputInfo
---@operator call: rizu.InputInfo
---@field time number
---@field rate number
---@field input_offset number
---@field timing_values sea.TimingValues
local InputInfo = class()

function InputInfo:new()
	self.time = 0
	self.rate = 1
	self.input_offset = 0
	self.timing_values = TimingValues()
end

---@param time number
function InputInfo:setTime(time)
	self.time = time
end

---@param rate number
function InputInfo:setRate(rate)
	self.rate = rate
end

---@param time number
---@return number
function InputInfo:sub(time)
	return (self.time - time) / self.rate
end

return InputInfo
