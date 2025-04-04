local class = require("class")
local path_util = require("path_util")
local md5 = require("md5")
local types = require("sea.shared.types")

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
	if not types.md5hash(hash) then
		return nil, "invalid hash"
	end

	local chartfile = self.cacheModel.chartfilesRepo:selectChartfileByHash(hash)
	if not chartfile then
		return nil, "chartfile not found"
	end

	local chartfile_set = self.cacheModel.chartfilesRepo:selectChartfileSetById(chartfile.set_id)
	if not chartfile_set then
		return nil, "chartfile_set not found"
	end

	local location = self.cacheModel.locationsRepo:selectLocationById(chartfile_set.location_id)
	if not location then
		return nil, "location not found"
	end

	local prefix = self.cacheModel.locationManager:getPrefix(location)
	local path = path_util.join(prefix, chartfile_set.dir, chartfile_set.name, chartfile.name)

	local data = love.filesystem.read(path)
	if not data then
		return nil, "file not found"
	end

	if md5.sumhexa(data) ~= hash then
		return nil, "hash mismatch"
	end

	return {
		name = chartfile.name,
		data = data,
	}
end

---@param events_hash string
---@return string?
---@return string?
function SubmissionClientRemote:getEventsData(events_hash)
	if not types.md5hash(events_hash) then
		return nil, "invalid hash"
	end

	local score = self.cacheModel.scoresRepo:getScoreByReplayHash(events_hash)
	if not score then
		return nil, "score not found"
	end

	local data = love.filesystem.read("userdata/replays/" .. events_hash)
	if not data then
		return nil, "replay file not found"
	end

	return data
end

return SubmissionClientRemote
