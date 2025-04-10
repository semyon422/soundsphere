local class = require("class")

---@class sea.FakeSubmissionClientRemote
---@operator call: sea.FakeSubmissionClientRemote
local FakeSubmissionClientRemote = class()

---@param chartfile_data string
---@param replayfile_data string
function FakeSubmissionClientRemote:new(chartfile_data, replayfile_data)
	self.chartfile_data = chartfile_data
	self.replayfile_data = replayfile_data
end

---@param hash string
---@return {name: string, data: string}?
---@return string?
function FakeSubmissionClientRemote:getChartfileData(hash)
	return {name = "file.bms", data = self.chartfile_data}
end

---@param replay_hash string
---@return string?
---@return string?
function FakeSubmissionClientRemote:getReplayData(replay_hash)
	return self.replayfile_data
end

return FakeSubmissionClientRemote
