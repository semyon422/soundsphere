local class = require("class")
local valid = require("valid")
local md5 = require("md5")
local Chartfile = require("sea.chart.Chartfile")
local ReplayCoder = require("sea.replays.ReplayCoder")

---@class sea.ComputeDataLoader
---@operator call: sea.ComputeDataLoader
local ComputeDataLoader = class()

---@param compute_data_provider sea.IComputeDataProvider
---@param chartfiles_repo sea.IChartfilesRepo
function ComputeDataLoader:new(chartfiles_repo, compute_data_provider)
	self.chartfiles_repo = chartfiles_repo
	self.compute_data_provider = compute_data_provider
end

---@param hash string
---@param user_id integer
---@return {chartfile: sea.Chartfile, data: string}?
---@return string?
function ComputeDataLoader:requireChartfile(hash, user_id)
	local chartfile = self.chartfiles_repo:getChartfileByHash(hash)
	if not chartfile then
		local chartfile_values = Chartfile()
		chartfile_values.hash = hash
		chartfile_values.creator_id = user_id
		chartfile_values.compute_state = "new"
		chartfile_values.submitted_at = os.time()
		chartfile = self.chartfiles_repo:createChartfile(chartfile_values)
	end

	local file, err = self.compute_data_provider:getChartData(hash)
	if not file then
		return nil, "get chartfile data: " .. err
	end

	if md5.sumhexa(file.data) ~= hash then
		return nil, "invalid hash"
	end

	chartfile.name = file.name
	chartfile.size = #file.data
	chartfile = self.chartfiles_repo:updateChartfile(chartfile)

	return {chartfile = chartfile, data = file.data}
end

---@param hash string
---@return {replay: sea.Replay, data: string}?
---@return string?
function ComputeDataLoader:requireReplay(hash)
	local replay_data, err = self.compute_data_provider:getReplayData(hash)
	if not replay_data then
		return nil, "get replay data: " .. (err or "missing error")
	end

	if type(replay_data) ~= "string" then
		return nil, "invalid replay data"
	end

	if md5.sumhexa(replay_data) ~= hash then
		return nil, "invalid replay hash"
	end

	local replay, err = ReplayCoder.decode(replay_data)
	if not replay then
		return nil, "can't decode replay: " .. err
	end

	local ok, err = valid.format(replay:validate())
	if not ok then
		return nil, "invalid replay: " .. err
	end

	return {
		replay = replay,
		data = replay_data,
	}
end

return ComputeDataLoader
