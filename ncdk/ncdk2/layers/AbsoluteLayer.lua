local Layer = require("ncdk2.layers.Layer")
local AbsolutePoint = require("ncdk2.tp.AbsolutePoint")
local AbsoluteCompute = require("ncdk2.compute.AbsoluteCompute")

---@class ncdk2.AbsoluteLayer: ncdk2.Layer
---@operator call: ncdk2.AbsoluteLayer
local AbsoluteLayer = Layer + {}

function AbsoluteLayer:new()
	Layer.new(self)
	self.absoluteCompute = AbsoluteCompute()
end

---@param time number
---@return ncdk2.AbsolutePoint
function AbsoluteLayer:newPoint(time)
	return AbsolutePoint(time)
end

---@param time number
---@return ncdk2.AbsolutePoint
function AbsoluteLayer:getPoint(time)
	---@type ncdk2.AbsolutePoint
	return Layer.getPoint(self, time)
end

function AbsoluteLayer:compute()
	self.absoluteCompute:compute(self:getPointList())
	Layer.compute(self)
end

function AbsoluteLayer:toInterval()
	local AbsoluteInterval = require("ncdk2.convert.AbsoluteInterval")
	local conv = AbsoluteInterval()
	conv:convert(self)
end

return AbsoluteLayer
