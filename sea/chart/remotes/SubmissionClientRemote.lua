local class = require("class")

---@class sea.SubmissionClientRemote: sea.IClientRemote
---@operator call: sea.SubmissionClientRemote
local SubmissionClientRemote = class()

---@param cacheModel sphere.CacheModel
function SubmissionClientRemote:new(cacheModel)
	self.cacheModel = cacheModel
end

---@param hash string
---@return {name: string, data: string}?
---@return string?
function SubmissionClientRemote:getChartfileData(hash)
	return self.cacheModel:getChartfileData(hash)
end

---@param replay_hash string
---@return string?
---@return string?
function SubmissionClientRemote:getReplayData(replay_hash)
	return self.cacheModel:getReplayData(replay_hash)
end

return SubmissionClientRemote
