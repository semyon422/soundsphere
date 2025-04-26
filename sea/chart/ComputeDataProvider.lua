local IComputeDataProvider = require("sea.chart.IComputeDataProvider")

---@class sea.ComputeDataProvider: sea.IComputeDataProvider
---@operator call: sea.ComputeDataProvider
local ComputeDataProvider = IComputeDataProvider + {}

---@param chartfiles_repo sea.ChartfilesRepo
---@param charts_storage sea.IKeyValueStorage
---@param replays_storage sea.IKeyValueStorage
function ComputeDataProvider:new(chartfiles_repo, charts_storage, replays_storage)
	self.chartfiles_repo = chartfiles_repo
	self.charts_storage = charts_storage
	self.replays_storage = replays_storage
end

---@param hash string
---@return {name: string, data: string}?
---@return string?
function ComputeDataProvider:getChartData(hash)
	local chartfile = self.chartfiles_repo:getChartfileByHash(hash)
	if not chartfile then
		return nil, "chartfile not found in repo"
	end

	if not chartfile.name then
		return nil, "missing name"
	end

	local data, err = self.charts_storage:get(hash)
	if not data then
		return nil, "storage get: " .. err
	end

	return {
		name = chartfile.name,
		data = data,
	}
end

---@param replay_hash string
---@return string?
---@return string?
function ComputeDataProvider:getReplayData(replay_hash)
	return self.replays_storage:get(replay_hash)
end

return ComputeDataProvider
