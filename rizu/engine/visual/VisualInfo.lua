local class = require("class")

---@class rizu.VisualInfo
---@operator call: rizu.VisualInfo
---@field time number
---@field rate number
---@field offset number
---@field shortening number
---@field const boolean
---@field logic_notes {[ncdk2.LinkedNote]: rizu.LogicNote?}
local VisualInfo = class()

function VisualInfo:new()
	self.time = 0
	self.rate = 1
	self.offset = 0
	self.shortening = 0
	self.const = false
	self.logic_notes = {}
end

---@param time number
---@return number
function VisualInfo:sub(time)
	return (self.time - time - self.offset) * self.rate
end

return VisualInfo
