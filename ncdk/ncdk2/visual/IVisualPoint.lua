local class = require("class")

---@class ncdk2.IVisualPoint
---@operator call: ncdk2.IVisualPoint
---@field point ncdk2.IPoint
---@field _expand ncdk2.Expand?
---@field _velocity ncdk2.Velocity?
---@field currentSpeed number
---@field localSpeed number
---@field globalSpeed number
local IVisualPoint = class()

---@param vp ncdk2.IVisualPoint?
---@return number
function IVisualPoint:getVisualTime(vp)
	return 0
end

return IVisualPoint
