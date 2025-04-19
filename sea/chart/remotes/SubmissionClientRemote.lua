local class = require("class")

---@class sea.SubmissionClientRemote: sea.IClientRemote
---@operator call: sea.SubmissionClientRemote
local SubmissionClientRemote = class()

---@param computeDataProvider sphere.ComputeDataProvider
function SubmissionClientRemote:new(computeDataProvider)
	self.computeDataProvider = computeDataProvider
end

---@param hash string
---@return {name: string, data: string}?
---@return string?
function SubmissionClientRemote:getChartfileData(hash)
	return self.computeDataProvider:getChartfileData(hash)
end

---@param replay_hash string
---@return string?
---@return string?
function SubmissionClientRemote:getReplayData(replay_hash)
	return self.computeDataProvider:getReplayData(replay_hash)
end

return SubmissionClientRemote
