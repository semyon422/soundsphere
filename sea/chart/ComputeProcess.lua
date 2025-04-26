local class = require("class")

---@class sea.ComputeProcess
---@operator call: sea.ComputeProcess
---@field id integer
---@field created_at integer
---@field completed_at integer?
---@field state sea.ComputeState
---@field target sea.ComputeTarget
---@field current integer
---@field total integer
local ComputeProcess = class()

return ComputeProcess
