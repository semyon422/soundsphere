local math_util = require("math_util")
local Interpolator = require("ncdk2.Interpolator")

---@class ncdk2.VisualInterpolator: ncdk2.Interpolator
---@operator call: ncdk2.VisualInterpolator
local VisualInterpolator = Interpolator + {}

---@param p ncdk2.VisualPoint
---@return ncdk2.Point
local function ext_point(p)
	return p.point
end

---@param list ncdk2.VisualPoint[]
---@param vp ncdk2.VisualPoint
---@param mode "absolute"|"visual"
function VisualInterpolator:interpolate(list, vp, mode)
	---@type integer
	local index
	if mode == "absolute" then
		index = self:getBaseIndex(list, vp, ext_point)
	else
		index = self:getBaseIndex(list, vp)
	end

	local a = list[index]
	local a_p = a.point
	local vp_p = vp.point

	if mode == "absolute" then
		local da = vp_p.absoluteTime - a_p.absoluteTime
		vp.visualTime = a.visualTime + da * a.currentSpeed
		vp.monotonicVisualTime = a.monotonicVisualTime + da * math.abs(a.currentSpeed)
	elseif mode == "visual" then
		local dm = vp.monotonicVisualTime - a.monotonicVisualTime
		vp.visualTime = a.visualTime + dm / math_util.sign(a.currentSpeed)
		vp_p.absoluteTime = a_p.absoluteTime + dm / math.abs(a.currentSpeed)
	end

	vp.section = a.section

	vp.currentSpeed = a.currentSpeed
	vp.localSpeed = a.localSpeed
	vp.globalSpeed = a.globalSpeed

	return index
end

return VisualInterpolator
