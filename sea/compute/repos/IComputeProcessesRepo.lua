local class = require("class")

---@class sea.IComputeProcessesRepo
---@operator call: sea.IComputeProcessesRepo
local IComputeProcessesRepo = class()

---@return sea.ComputeProcess[]
function IComputeProcessesRepo:getComputeProcesses()
	return {}
end

---@param id integer
---@return sea.ComputeProcess?
function IComputeProcessesRepo:getComputeProcess(id)
	return {}
end

---@param compute_process sea.ComputeProcess
---@return sea.ComputeProcess
function IComputeProcessesRepo:createComputeProcess(compute_process)
	return compute_process
end

---@param compute_process sea.ComputeProcess
---@return sea.ComputeProcess
function IComputeProcessesRepo:updateComputeProcess(compute_process)
	return compute_process
end

return IComputeProcessesRepo
