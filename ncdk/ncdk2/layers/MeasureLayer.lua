local Layer = require("ncdk2.layers.Layer")
local MeasurePoint = require("ncdk2.tp.MeasurePoint")
local MeasureCompute = require("ncdk2.compute.MeasureCompute")

---@class ncdk2.MeasureLayer: ncdk2.Layer
---@operator call: ncdk2.MeasureLayer
local MeasureLayer = Layer + {}

function MeasureLayer:new()
	Layer.new(self)
	self.measureCompute = MeasureCompute()
end

---@param mode string
function MeasureLayer:setSignatureMode(mode)
	assert(mode == "long" or mode == "short", "Wrong signature mode")
	self.signatureMode = mode
end

---@param time ncdk.Fraction
---@param isRightSide boolean?
---@return ncdk2.MeasurePoint
function MeasureLayer:newPoint(time, isRightSide)
	return MeasurePoint(time, isRightSide)
end

---@param time ncdk.Fraction
---@param isRightSide boolean?
---@return ncdk2.MeasurePoint
function MeasureLayer:getPoint(time, isRightSide)
	---@type ncdk2.MeasurePoint
	return Layer.getPoint(self, time, isRightSide)
end

function MeasureLayer:compute()
	self.measureCompute:compute(self:getPointList())
	Layer.compute(self)
end

function MeasureLayer:toInterval()
	local MeasureInterval = require("ncdk2.convert.MeasureInterval")
	local conv = MeasureInterval()
	conv:convert(self)
end

function MeasureLayer:toAbsolute()
	local IntervalAbsolute = require("ncdk2.convert.IntervalAbsolute")
	self:toInterval()
	---@cast self -ncdk2.MeasureLayer, +ncdk2.IntervalLayer
	local conv2 = IntervalAbsolute()
	conv2:convert(self)
end

return MeasureLayer
