local class = require("class")

---@class sea.ComputeTasksRepo
---@operator call: sea.ComputeTasksRepo
local ComputeTasksRepo = class()

---@param models rdb.Models
function ComputeTasksRepo:new(models)
	self.models = models
end

---@return sea.ComputeTask[]
function ComputeTasksRepo:getComputeTasks()
	return self.models.compute_tasks:select()
end

---@param id integer
---@return sea.ComputeTask?
function ComputeTasksRepo:getComputeTask(id)
	return self.models.compute_tasks:find({id = assert(id)})
end

---@param compute_task sea.ComputeTask
---@return sea.ComputeTask
function ComputeTasksRepo:createComputeTask(compute_task)
	return self.models.compute_tasks:create(compute_task)
end

---@param compute_task sea.ComputeTask
---@return sea.ComputeTask
function ComputeTasksRepo:updateComputeTask(compute_task)
	return self.models.compute_tasks:update(compute_task, {id = assert(compute_task.id)})[1]
end

---@param id integer
---@return sea.ComputeTask?
function ComputeTasksRepo:deleteComputeTask(id)
	return self.models.compute_tasks:delete({id = assert(id)})[1]
end

return ComputeTasksRepo
