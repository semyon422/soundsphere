local class = require("class")
local ComputeTask = require("sea.compute.ComputeTask")

---@class sea.ComputeProcessor
---@operator call: sea.ComputeProcessor
local ComputeProcessor = class()

---@param charts_computer sea.ChartsComputer
---@param compute_tasks_repo sea.ComputeTasksRepo
function ComputeProcessor:new(charts_computer, compute_tasks_repo)
	self.charts_computer = charts_computer
	self.compute_tasks_repo = compute_tasks_repo
end

---@return sea.ComputeTask[]
function ComputeProcessor:getComputeTasks()
	return self.compute_tasks_repo:getComputeTasks()
end

---@param id integer
---@return sea.ComputeTask?
function ComputeProcessor:getComputeTask(id)
	return self.compute_tasks_repo:getComputeTask(id)
end

---@param time integer
---@param state sea.ComputeState
---@param total integer
---@return sea.ComputeTask
function ComputeProcessor:startChartplays(time, state, total)
	local compute_task = ComputeTask()

	compute_task.created_at = time
	compute_task.current = 0
	compute_task.target = "chartplays"
	compute_task.state = state
	compute_task.total = total

	compute_task = self.compute_tasks_repo:createComputeTask(compute_task)

	return compute_task
end

---@param compute_task sea.ComputeTask
---@param chartplays sea.Chartplay[]
---@return sea.ComputeTask
function ComputeProcessor:stepChartplays(compute_task, chartplays)
	local charts_computer = self.charts_computer

	for _, chartplay in ipairs(chartplays) do
		local ret, err = charts_computer:computeChartplay(chartplay)
		if not ret then
			print(err)
		end
	end

	compute_task.current = compute_task.current + #chartplays

	if compute_task.current >= compute_task.total then
		compute_task.completed_at = os.time()
	end

	self.compute_tasks_repo:updateComputeTask(compute_task)

	return compute_task
end

---@param compute_task sea.ComputeTask
---@param chartplays sea.Chartplay[]
---@return sea.ComputeTask
function ComputeProcessor:step(compute_task, chartplays)
	if compute_task.target == "chartplays" then
		return self:stepChartplays(compute_task, chartplays)
	end
	error()
end

---@return sea.ComputeTask?
function ComputeProcessor:deleteProcess(id)
	return self.compute_tasks_repo:deleteComputeTask(id)
end

return ComputeProcessor
