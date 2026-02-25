local class = require("class")

---@class yi.ScrollPhysics
---@operator call: yi.ScrollPhysics
---@field momentum_friction number Friction during momentum
---@field min_velocity number Minimum velocity before stopping
---@field overscroll_resistance number Resistance when overscrolling
---@field lerp_return_speed number Lerp speed for returning to bounds
---@field tween_duration number Duration of linear tween in seconds
local ScrollPhysics = class()

function ScrollPhysics:new()
	self.momentum_friction = 0.94
	self.min_velocity = 0.01
	self.overscroll_resistance = 0.4
	self.lerp_return_speed = 10
	self.tween_duration = 0.10
end

return ScrollPhysics
