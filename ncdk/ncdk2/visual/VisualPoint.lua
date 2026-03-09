local IVisualPoint = require("ncdk2.visual.IVisualPoint")

---@class ncdk2.VisualPoint: ncdk2.IVisualPoint
---@operator call: ncdk2.VisualPoint
---@field _expand ncdk2.Expand?
---@field _velocity ncdk2.Velocity?
---@field compare_index integer
local VisualPoint = IVisualPoint + {}

VisualPoint.visualTime = 0
VisualPoint.monotonicVisualTime = 0
VisualPoint.section = 0
VisualPoint.currentSpeed = 1
VisualPoint.localSpeed = 1
VisualPoint.globalSpeed = 1

---@param point ncdk2.Point
function VisualPoint:new(point)
	self.point = point
end

---@param vp ncdk2.VisualPoint?
---@return number
function VisualPoint:getVisualTime(vp)
	if not vp then
		return self.point.absoluteTime
	end
	if self.section ~= vp.section then
		return (self.section - vp.section) / 0
	end
	local globalSpeed = vp.globalSpeed
	local localSpeed = self.localSpeed
	return (self.visualTime - vp.visualTime) * globalSpeed * localSpeed + vp.point.absoluteTime
end

---@param currentSpeed number
---@param localSpeed number
---@param globalSpeed number
function VisualPoint:setSpeeds(currentSpeed, localSpeed, globalSpeed)
	self.currentSpeed = currentSpeed
	self.localSpeed = localSpeed
	self.globalSpeed = globalSpeed
end

---@param vp ncdk2.VisualPoint
---@return boolean
function VisualPoint:compare(vp)
	if self.section ~= vp.section then
		return self.section < vp.section
	end
	if self.monotonicVisualTime ~= vp.monotonicVisualTime then
		return self.monotonicVisualTime < vp.monotonicVisualTime
	end
	if self.point.absoluteTime ~= vp.point.absoluteTime then
		return self.point.absoluteTime < vp.point.absoluteTime
	end
	return false
end

---@param a ncdk2.VisualPoint
---@return string
function VisualPoint.__tostring(a)
	return ("VisualPoint(%s)"):format(a.point)
end

---@param a ncdk2.VisualPoint
---@param b ncdk2.VisualPoint
---@return boolean
function VisualPoint.__lt(a, b)
	if a.point.absoluteTime ~= b.point.absoluteTime then
		return a.point.absoluteTime < b.point.absoluteTime
	end
	return a.compare_index < b.compare_index
end

return VisualPoint
