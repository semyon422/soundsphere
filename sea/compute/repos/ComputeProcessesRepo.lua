local class = require("class")

---@class sea.ComputeProcessesRepo
---@operator call: sea.ComputeProcessesRepo
local ComputeProcessesRepo = class()

---@param models rdb.Models
function ComputeProcessesRepo:new(models)
	self.models = models
end

---@return sea.ComputeProcess[]
function ComputeProcessesRepo:getComputeProcesses()
	return self.models.compute_processes:select()
end

---@param id integer
---@return sea.ComputeProcess?
function ComputeProcessesRepo:getComputeProcess(id)
	return self.models.compute_processes:find({id = assert(id)})
end

---@param compute_process sea.ComputeProcess
---@return sea.ComputeProcess
function ComputeProcessesRepo:createComputeProcess(compute_process)
	return self.models.compute_processes:create(compute_process)
end

---@param compute_process sea.ComputeProcess
---@return sea.ComputeProcess
function ComputeProcessesRepo:updateComputeProcess(compute_process)
	return self.models.compute_processes:update(compute_process, {id = assert(compute_process.id)})[1]
end

return ComputeProcessesRepo
