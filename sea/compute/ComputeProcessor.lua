local class = require("class")
local ComputeProcess = require("sea.compute.ComputeProcess")

---@class sea.ComputeProcessor
---@operator call: sea.ComputeProcessor
local ComputeProcessor = class()

---@param charts_computer sea.ChartsComputer
---@param compute_processes_repo sea.ComputeProcessesRepo
function ComputeProcessor:new(charts_computer, compute_processes_repo)
	self.charts_computer = charts_computer
	self.compute_processes_repo = compute_processes_repo
end

---@return sea.ComputeProcess[]
function ComputeProcessor:getComputeProcesses()
	return self.compute_processes_repo:getComputeProcesses()
end

---@param id integer
---@return sea.ComputeProcess?
function ComputeProcessor:getComputeProcess(id)
	return self.compute_processes_repo:getComputeProcess(id)
end

---@param time integer
---@param state sea.ComputeState
---@param total integer
---@return sea.ComputeProcess
function ComputeProcessor:startChartplays(time, state, total)
	local compute_process = ComputeProcess()

	compute_process.created_at = time
	compute_process.current = 0
	compute_process.target = "chartplays"
	compute_process.state = state
	compute_process.total = total

	compute_process = self.compute_processes_repo:createComputeProcess(compute_process)

	return compute_process
end

---@param compute_process sea.ComputeProcess
---@param chartplays sea.Chartplay[]
---@return sea.ComputeProcess
function ComputeProcessor:stepChartplays(compute_process, chartplays)
	local charts_computer = self.charts_computer

	for _, chartplay in ipairs(chartplays) do
		charts_computer:computeChartplay(chartplay)
	end

	compute_process.current = compute_process.current + #chartplays

	if compute_process.current >= compute_process.total then
		compute_process.completed_at = os.time()
	end

	self.compute_processes_repo:updateComputeProcess(compute_process)

	return compute_process
end

---@param compute_process sea.ComputeProcess
---@param chartplays sea.Chartplay[]
---@return sea.ComputeProcess
function ComputeProcessor:step(compute_process, chartplays)
	if compute_process.target == "chartplays" then
		return self:stepChartplays(compute_process, chartplays)
	end
	error()
end

---@return sea.ComputeProcess?
function ComputeProcessor:deleteProcess(id)
	return self.compute_processes_repo:deleteComputeProcess(id)
end

return ComputeProcessor
