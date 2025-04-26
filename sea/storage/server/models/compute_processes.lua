local ComputeProcess = require("sea.chart.ComputeProcess")
local ComputeState = require("sea.chart.ComputeState")
local ComputeTarget = require("sea.chart.ComputeTarget")

---@type rdb.ModelOptions
local compute_processes = {}

compute_processes.metatable = ComputeProcess

compute_processes.types = {
	state = ComputeState,
	target = ComputeTarget,
}

return compute_processes
