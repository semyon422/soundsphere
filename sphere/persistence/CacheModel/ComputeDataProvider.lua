local IComputeDataProvider = require("sea.compute.IComputeDataProvider")
local path_util = require("path_util")
local md5 = require("md5")
local types = require("sea.shared.types")

---@class sphere.ComputeDataProvider: sea.IComputeDataProvider
---@operator call: sphere.ComputeDataProvider
local ComputeDataProvider = IComputeDataProvider + {}

---@param chartfilesRepo sphere.ChartfilesRepo
---@param chartsRepo sea.ChartsRepo
---@param locationsRepo sphere.LocationsRepo
---@param locationManager sphere.LocationManager
function ComputeDataProvider:new(chartfilesRepo, chartsRepo, locationsRepo, locationManager)
	self.chartfilesRepo = chartfilesRepo
	self.chartsRepo = chartsRepo
	self.locationsRepo = locationsRepo
	self.locationManager = locationManager
end

---@param hash string
---@return {name: string, data: string}?
---@return string?
function ComputeDataProvider:getChartData(hash)
	if not types.md5hash(hash) then
		return nil, "invalid hash"
	end

	local chartfile = self.chartfilesRepo:selectChartfileByHash(hash)
	if not chartfile then
		return nil, "chartfile not found"
	end

	local chartfile_set = self.chartfilesRepo:selectChartfileSetById(chartfile.set_id)
	if not chartfile_set then
		return nil, "chartfile_set not found"
	end

	local location = self.locationsRepo:selectLocationById(chartfile_set.location_id)
	if not location then
		return nil, "location not found"
	end

	local prefix = self.locationManager:getPrefix(location)
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

---@param replay_hash string
---@return string?
---@return string?
function ComputeDataProvider:getReplayData(replay_hash)
	if not types.md5hash(replay_hash) then
		return nil, "invalid hash"
	end

	local chartplay = self.chartsRepo:getChartplayByReplayHash(replay_hash)
	if not chartplay then
		return nil, "chartplay not found"
	end

	local data = love.filesystem.read("userdata/replays/" .. replay_hash)
	if not data then
		return nil, "replay file not found"
	end

	if md5.sumhexa(data) ~= replay_hash then
		return nil, "hash mismatch"
	end

	return data
end

return ComputeDataProvider
