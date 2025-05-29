local ComputeTask = require("sea.compute.ComputeTask")
local ComputeState = require("sea.compute.ComputeState")
local ComputeTarget = require("sea.compute.ComputeTarget")

---@type rdb.ModelOptions
local compute_tasks = {}

compute_tasks.metatable = ComputeTask

compute_tasks.types = {
	state = ComputeState,
	target = ComputeTarget,
}

return compute_tasks
