local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")
local md5 = require("md5")
local Chartfile = require("sea.chart.Chartfile")
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
---@return sea.Chartfile?
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

	local file, err = submission:getChartfileData(hash)
	if not file then
		return nil, err or "missing error"
	end

	if not validate_chartfile_data(file) then
		return nil, "invalid chartfile data"
	end

	if md5.sumhexa(file.data) ~= hash then
		return nil, "invalid hash"
	end

	local ok, err = self.charts_storage:set(hash, file.data)
	if not ok then
		return nil, err
	end

	chartfile.name = file.name
	chartfile.size = #file.data
	chartfile.submitted_at = os.time()
	self.charts_repo:updateChartfile(chartfile)

	return chartfile
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
		return nil, err
	end

	local chartplay = self.charts_repo:getChartplayByEventsHash(chartplay_values.events_hash)
	if not chartplay then
		chartplay_values.id = nil
		chartplay_values.user_id = user.id
		chartplay_values.created_at = os.time()
		chartplay_values.compute_state = "new"

		chartplay = self.charts_repo:createChartplay(chartplay_values)
	end

	local chartfile, err = self:requireChartfile(user, submission, chartplay.hash)
	if not chartfile then
		return nil, err
	end

	local events_data, err = submission:getEventsData(chartplay.events_hash)
	if not events_data then
		return nil, err or "missing error"
	end

	if type(events_data) ~= "string" then
		return nil, "invalid events data"
	end

	if md5.sumhexa(events_data) ~= chartplay.events_hash then
		return nil, "invalid replay hash"
	end

	local ok, err = self.replays_storage:set(chartplay.events_hash, events_data)
	if not ok then
		return nil, err
	end

	chartplay.submitted_at = os.time()
	self.charts_repo:updateChartplay(chartplay)

	---@type sea.Chartplay, sea.Chartdiff
	local computed_chartplay, computed_chartdiff

	if chartplay.custom then
		computed_chartplay = chartplay
		computed_chartdiff = chartdiff_values
		computed_chartdiff.custom_user_id = user.id
	else
		local cpcd, err = self.chartplay_computer:compute(chartplay)
		if not cpcd then
			chartplay.compute_state = "invalid"
			self.charts_repo:updateChartplay(chartplay)
			return nil, err
		end

		computed_chartplay, computed_chartdiff = cpcd[1], cpcd[2]

		if not chartplay:equalsComputed(computed_chartplay) then
			chartplay.compute_state = "invalid"
			self.charts_repo:updateChartplay(chartplay)
			return nil, "computed chartplay differs"
		end

		if not chartdiff_values:equalsComputed(computed_chartdiff) then
			return nil, "computed values differs"
		end
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

	if not chartplay.custom then
		self.leaderboards:addChartplay(chartplay)
	end

	return chartplay
end

return Chartplays
