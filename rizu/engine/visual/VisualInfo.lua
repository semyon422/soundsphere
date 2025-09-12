local class = require("class")

---@class rizu.VisualInfo
---@operator call: rizu.VisualInfo
---@field time number
---@field rate number
---@field input_offset number
---@field visual_offset number
---@field shortening number
---@field const boolean
---@field logic_notes {[ncdk2.LinkedNote]: rizu.LogicNote?}
local VisualInfo = class()

function VisualInfo:new()
	self.time = 0
	self.rate = 1
	self.input_offset = 0
	self.visual_offset = 0
	self.shortening = 0
	self.const = false
	self.logic_notes = {}
end

return VisualInfo
