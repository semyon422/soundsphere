local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")
local md5 = require("md5")
local Chartfile = require("sea.chart.Chartfile")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")
local ReplayCoder = require("sea.replays.ReplayCoder")
local ChartplaysAccess = require("sea.chart.access.ChartplaysAccess")

---@class sea.Chartplays
---@operator call: sea.Chartplays
local Chartplays = class()

---@param charts_repo sea.IChartsRepo
---@param chartplay_computer sea.IChartplayComputer
---@param charts_storage sea.IKeyValueStorage
---@param replays_storage sea.IKeyValueStorage
---@param leaderboards sea.Leaderboards
function Chartplays:new(
	charts_repo,
	chartplay_computer,
	charts_storage,
	replays_storage,
	leaderboards
)
	self.charts_repo = charts_repo
	self.chartplay_computer = chartplay_computer
	self.charts_storage = charts_storage
	self.replays_storage = replays_storage
	self.leaderboards = leaderboards
	self.chartplays_access = ChartplaysAccess()
end

---@return sea.Chartplay[]
function Chartplays:getChartplays()
	return self.charts_repo:getChartplays()
end

local validate_chartfile_data = valid.struct({
	name = types.file_name,
	data = types.binary,
})

---@param user sea.User
---@param submission sea.SubmissionClientRemote
---@param hash string
---@return {chartfile: sea.Chartfile, data: string}?
---@return string?
function Chartplays:requireChartfile(user, submission, hash)
	local chartfile = self.charts_repo:getChartfileByHash(hash)
	if not chartfile then
		local chartfile_values = Chartfile()
		chartfile_values.hash = hash
		chartfile_values.creator_id = user.id
		chartfile_values.compute_state = "new"
		chartfile_values.submitted_at = os.time()
		chartfile = self.charts_repo:createChartfile(chartfile_values)
	end

	---@type string?
	local file_data
	if chartfile.name then
		file_data = self.charts_storage:get(hash)
	end

	if file_data then
		return {chartfile = chartfile, data = file_data}
	end

	local file, err = submission:getChartfileData(hash)
	if not file then
		return nil, "get chartfile data: " .. (err or "missing error")
	end

	if not validate_chartfile_data(file) then
		return nil, "invalid chartfile data"
	end

	if md5.sumhexa(file.data) ~= hash then
		return nil, "invalid hash"
	end

	local ok, err = self.charts_storage:set(hash, file.data)
	if not ok then
		return nil, "storage set: " .. err
	end

	chartfile.name = file.name
	chartfile.size = #file.data
	chartfile.submitted_at = os.time()
	chartfile = self.charts_repo:updateChartfile(chartfile)

	return {chartfile = chartfile, data = file.data}
end

---@param submission sea.SubmissionClientRemote
---@param hash string
---@return sea.Replay?
---@return string?
function Chartplays:requireReplay(submission, hash)
	local replay_data, err = submission:getReplayData(hash)
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

	local ok, err = self.replays_storage:set(hash, replay_data)
	if not ok then
		return nil, "storage set: " .. err
	end

	return replay
end

---@param user sea.User
---@param submission sea.SubmissionClientRemote
---@param chartplay_values sea.Chartplay
---@param chartdiff_values sea.Chartdiff
---@return sea.Chartplay?
---@return string?
function Chartplays:submit(user, submission, chartplay_values, chartdiff_values)
	local can, err = self.chartplays_access:canSubmit(user)
	if not can then
		return nil, "can submit: " .. err
	end

	local chartplay = self.charts_repo:getChartplayByReplayHash(chartplay_values.replay_hash)
	if not chartplay then
		chartplay_values.id = nil
		chartplay_values.user_id = user.id
		chartplay_values.submitted_at = os.time()
		chartplay_values.compute_state = "new"

		chartplay = self.charts_repo:createChartplay(chartplay_values)
	end

	assert(chartplay_values:equalsChartplay(chartplay))

	local chartfile_and_data, err = self:requireChartfile(user, submission, chartplay.hash)
	if not chartfile_and_data then
		return nil, "require chartfile: " .. err
	end

	local chartfile = chartfile_and_data.chartfile
	local chartfile_data = chartfile_and_data.data

	local replay, err = self:requireReplay(submission, chartplay.replay_hash)
	if not replay then
		return nil, "require replay: " .. err
	end

	if not replay:equalsChartplayBase(chartplay) then
		return nil, "chartplay base of replay differs"
	elseif not replay:equalsChartmetaKey(chartplay) then
		return nil, "chartmeta key of replay differs"
	end

	---@type sea.Chartdiff
	local computed_chartdiff
	---@type sea.Chartmeta
	local computed_chartmeta

	if chartplay.custom then
		computed_chartdiff = chartdiff_values
		computed_chartdiff.custom_user_id = user.id

		computed_chartmeta, err = self.chartplay_computer:computeChartmeta(chartfile.name, chartfile_data, chartplay.index)
		if not computed_chartmeta then
			chartplay.compute_state = "invalid"
			self.charts_repo:updateChartplay(chartplay)
			return nil, "compute chartmeta: " .. err
		end
	else
		local ret, err = self.chartplay_computer:compute(
			chartfile.name, chartfile_data, chartplay.index, replay
		)
		if not ret then
			chartplay.compute_state = "invalid"
			self.charts_repo:updateChartplay(chartplay)
			return nil, "compute: " .. err
		end

		computed_chartdiff = ret.chartdiff
		computed_chartmeta = ret.chartmeta

		if not chartplay:equalsComputed(ret.chartplay_computed) then
			chartplay.compute_state = "invalid"
			self.charts_repo:updateChartplay(chartplay)
			return nil, "computed chartplay differs"
		end

		if not chartdiff_values:equalsComputed(computed_chartdiff) then
			return nil, "computed values differs"
		end
	end

	local timings = chartplay.timings or computed_chartmeta.timings
	if not timings then
		return nil, "missing timings"
	end

	local subtimings = chartplay.subtimings

	local timing_values = TimingValuesFactory:get(timings, subtimings)
	if not timing_values then
		chartplay.compute_state = "invalid"
		self.charts_repo:updateChartplay(chartplay)
		return nil, "timing values differs"
	end

	chartplay.compute_state = "valid"
	self.charts_repo:updateChartplay(chartplay)

	local chartdiff = self.charts_repo:getChartdiffByChartkey(computed_chartdiff)
	if not chartdiff then
		self.charts_repo:createChartdiff(computed_chartdiff)
	elseif not chartdiff:equalsComputed(computed_chartdiff) then
		computed_chartdiff.id = chartdiff.id
		self.charts_repo:updateChartdiff(computed_chartdiff)
		-- add a note on chartdiff page about this change
	end

	local chartmeta = self.charts_repo:getChartmetaByHashIndex(computed_chartmeta.hash, computed_chartmeta.index)
	if not chartmeta then
		self.charts_repo:createChartmeta(computed_chartmeta)
	elseif not chartmeta:equalsComputed(computed_chartmeta) then
		computed_chartmeta.id = chartmeta.id
		self.charts_repo:updateChartmeta(computed_chartmeta)
		-- add a note on chartmeta page about this change
	end

	if not chartplay.custom then
		self.leaderboards:addChartplay(chartplay)
	end

	return chartplay
end

return Chartplays
