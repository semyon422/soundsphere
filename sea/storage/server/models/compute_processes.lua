local ComputeProcess = require("sea.compute.ComputeProcess")
local ComputeState = require("sea.compute.ComputeState")
local ComputeTarget = require("sea.compute.ComputeTarget")

---@type rdb.ModelOptions
local compute_processes = {}

compute_processes.metatable = ComputeProcess

compute_processes.types = {
	state = ComputeState,
	target = ComputeTarget,
}

return compute_processes
