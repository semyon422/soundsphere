local class = require("class")
local ComputeProcess = require("sea.chart.ComputeProcess")

---@class sea.ComputeProcessor
---@operator call: sea.ComputeProcessor
local ComputeProcessor = class()

---@param compute_data_loader sea.ComputeDataLoader
---@param chartplay_computer sea.IChartplayComputer
---@param charts_repo sea.IChartsRepo
---@param compute_processes_repo sea.IComputeProcessesRepo
function ComputeProcessor:new(compute_data_loader, chartplay_computer, charts_repo, compute_processes_repo)
	self.compute_data_loader = compute_data_loader
	self.chartplay_computer = chartplay_computer
	self.charts_repo = charts_repo
	self.compute_processes_repo = compute_processes_repo
end

---@param time integer
---@param state sea.ComputeState
---@return sea.ComputeProcess
function ComputeProcessor:startChartplays(time, state)
	local compute_process = ComputeProcess()

	compute_process.created_at = time
	compute_process.current = 0
	compute_process.target = "chartplays"
	compute_process.state = state
	compute_process.total = self.charts_repo:getChartplaysComputedCount(time, state)

	compute_process = self.compute_processes_repo:createComputeProcess(compute_process)

	return compute_process
end

---@param chartplay sea.Chartplay
---@return true?
---@return string?
function ComputeProcessor:computeChartplay(chartplay)
	local charts_repo = self.charts_repo
	local compute_data_loader = self.compute_data_loader
	local chartplay_computer = self.chartplay_computer

	local chart_file_data, err = compute_data_loader:requireChart(chartplay.hash)
	if not chart_file_data then
		return nil, "require chart: " .. err
	end

	local replay_and_data, err = compute_data_loader:requireReplay(chartplay.replay_hash)
	if not replay_and_data then
		return nil, "require replay" .. err
	end

	local replay = replay_and_data.replay

	local ret, err = chartplay_computer:compute(
		chart_file_data.name,
		chart_file_data.data,
		chartplay.index,
		replay
	)
	if not ret then
		chartplay.compute_state = "invalid"
		chartplay.computed_at = os.time()
		self.charts_repo:updateChartplay(chartplay)
		return
	end

	local computed_chartdiff = ret.chartdiff
	local computed_chartmeta = ret.chartmeta
	local chartplay_computed = ret.chartplay_computed

	chartplay:importChartplayBase(replay)
	chartplay:importChartplayComputed(chartplay_computed)

	chartplay.compute_state = "valid"
	chartplay.computed_at = os.time()
	self.charts_repo:updateChartplay(chartplay)

	-- update chartdiffs, chartmetas, leaderboards
end

---@param compute_process sea.ComputeProcess
---@return sea.ComputeProcess
function ComputeProcessor:stepChartplays(compute_process)
	local charts_repo = self.charts_repo

	local chartplays = charts_repo:getChartplaysComputed(
		compute_process.created_at,
		compute_process.state,
		10
	)

	for _, chartplay in ipairs(chartplays) do
		self:computeChartplay(chartplay)
	end

	compute_process.current = compute_process.current + #chartplays

	if compute_process.current >= compute_process.total then
		compute_process.completed_at = os.time()
	end

	self.compute_processes_repo:updateComputeProcess(compute_process)

	return compute_process
end

---@param compute_process sea.ComputeProcess
---@return sea.ComputeProcess
function ComputeProcessor:step(compute_process)
	if compute_process.target == "chartplays" then
		return self:stepChartplays(compute_process)
	end
	error()
end

return ComputeProcessor
