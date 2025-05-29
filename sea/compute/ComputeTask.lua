local class = require("class")

---@class sea.ComputeTask
---@operator call: sea.ComputeTask
---@field id integer
---@field created_at integer
---@field completed_at integer?
---@field state sea.ComputeState
---@field target sea.ComputeTarget
---@field current integer
---@field total integer
local ComputeTask = class()

return ComputeTask
