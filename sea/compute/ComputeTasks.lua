local class = require("class")
local ComputeTask = require("sea.compute.ComputeTask")

---@class sea.ComputeTasks
---@operator call: sea.ComputeTasks
local ComputeTasks = class()

---@param compute_tasks_repo sea.ComputeTasksRepo
function ComputeTasks:new(compute_tasks_repo)
	self.compute_tasks_repo = compute_tasks_repo
end

---@return sea.ComputeTask[]
function ComputeTasks:getComputeTasks()
	return self.compute_tasks_repo:getComputeTasks()
end

---@param id integer
---@return sea.ComputeTask?
function ComputeTasks:getComputeTask(id)
	return self.compute_tasks_repo:getComputeTask(id)
end

---@param time integer
---@param target sea.ComputeTarget
---@param state sea.ComputeState
---@param total integer
---@return sea.ComputeTask
function ComputeTasks:createComputeTask(time, target, state, total)
	local compute_task = ComputeTask()

	compute_task.created_at = time
	compute_task.current = 0
	compute_task.target = target
	compute_task.state = state
	compute_task.total = total

	compute_task = self.compute_tasks_repo:createComputeTask(compute_task)

	return compute_task
end

---@param compute_task sea.ComputeTask
---@param count integer
---@return sea.ComputeTask
function ComputeTasks:step(compute_task, count)
	compute_task.current = compute_task.current + count

	if compute_task.current >= compute_task.total then
		compute_task.completed_at = os.time()
	end

	self.compute_tasks_repo:updateComputeTask(compute_task)

	return compute_task
end

---@return sea.ComputeTask?
function ComputeTasks:deleteProcess(id)
	return self.compute_tasks_repo:deleteComputeTask(id)
end

return ComputeTasks
