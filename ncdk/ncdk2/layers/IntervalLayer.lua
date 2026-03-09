local Layer = require("ncdk2.layers.Layer")
local IntervalPoint = require("ncdk2.tp.IntervalPoint")
local IntervalCompute = require("ncdk2.compute.IntervalCompute")

---@class ncdk2.IntervalLayer: ncdk2.Layer
---@operator call: ncdk2.IntervalLayer
local IntervalLayer = Layer + {}

function IntervalLayer:new()
	Layer.new(self)
	self.intervalCompute = IntervalCompute()
end

---@param time ncdk.Fraction
---@return ncdk2.IntervalPoint
function IntervalLayer:newPoint(time)
	return IntervalPoint(time)
end

---@param time ncdk.Fraction
---@return ncdk2.IntervalPoint
function IntervalLayer:getPoint(time)
	---@type ncdk2.IntervalPoint
	return Layer.getPoint(self, time)
end

function IntervalLayer:compute()
	self.intervalCompute:compute(self:getPointList())
	Layer.compute(self)
end

function IntervalLayer:toAbsolute()
	local IntervalAbsolute = require("ncdk2.convert.IntervalAbsolute")
	local conv = IntervalAbsolute()
	conv:convert(self)
end

return IntervalLayer
