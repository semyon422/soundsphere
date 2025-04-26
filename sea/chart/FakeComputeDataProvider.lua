local class = require("class")

---@class sea.FakeComputeDataProvider
---@operator call: sea.FakeComputeDataProvider
local FakeComputeDataProvider = class()

---@param chartfile_name string
---@param chartfile_data string
---@param replayfile_data string
function FakeComputeDataProvider:new(chartfile_name, chartfile_data, replayfile_data)
	self.chartfile_name = chartfile_name
	self.chartfile_data = chartfile_data
	self.replayfile_data = replayfile_data
end

---@param hash string
---@return {name: string, data: string}?
---@return string?
function FakeComputeDataProvider:getChartData(hash)
	return {
		name = self.chartfile_name,
		data = self.chartfile_data,
	}
end

---@param replay_hash string
---@return string?
---@return string?
function FakeComputeDataProvider:getReplayData(replay_hash)
	return self.replayfile_data
end

return FakeComputeDataProvider
