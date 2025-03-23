local class = require("class")
local md5 = require("md5")
local Chartfile = require("sea.chart.Chartfile")
local ChartplaysAccess = require("sea.chart.access.ChartplaysAccess")

---@class sea.Chartplays
---@operator call: sea.Chartplays
local Chartplays = class()

---@param charts_repo sea.IChartsRepo
---@param chartplayComputer sea.IChartplayComputer
---@param chartsStorage sea.IKeyValueStorage
---@param replaysStorage sea.IKeyValueStorage
---@param leaderboards sea.Leaderboards
function Chartplays:new(
	charts_repo,
	chartplayComputer,
	chartsStorage,
	replaysStorage,
	leaderboards
)
	self.charts_repo = charts_repo
	self.chartplayComputer = chartplayComputer
	self.chartsStorage = chartsStorage
	self.replaysStorage = replaysStorage
	self.leaderboards = leaderboards
	self.chartplaysAccess = ChartplaysAccess()
end

---@return sea.Chartplay[]
function Chartplays:getChartplays()
	return self.charts_repo:getChartplays()
end

---@param user sea.User
---@param remote sea.ISubmissionClientRemote
---@param hash string
---@return sea.Chartfile?
---@return string?
function Chartplays:requireChartfile(user, remote, hash)
	local chartfile = self.charts_repo:getChartfileByHash(hash)
	if not chartfile then
		local chartfile_values = Chartfile()
		chartfile_values.hash = hash
		chartfile_values.creator_id = user.id
		chartfile_values.compute_state = "new"
		chartfile_values.submitted_at = os.time()
		chartfile = self.charts_repo:createChartfile(chartfile_values)
	end

	local file, err = remote:getChartfileData(hash)
	if not file then
		return nil, err or "missing error"
	end

	if md5.sumhexa(file.data) ~= hash then
		return nil, "invalid hash"
	end

	local ok, err = self.chartsStorage:set(hash, file.data)
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
---@param remote sea.ISubmissionClientRemote
---@param chartplay_values sea.Chartplay
---@return sea.Chartplay?
---@return string?
function Chartplays:submit(user, remote, chartplay_values)
	local can, err = self.chartplaysAccess:canSubmit(user)
	if not can then
		return nil, err
	end

	local chartplay = self.charts_repo:getChartplayByEventsHash(chartplay_values.events_hash)
	if not chartplay then
		chartplay_values.id = nil
		chartplay_values.user_id = user.id
		chartplay_values.created_at = os.time()

		chartplay = self.charts_repo:createChartplay(chartplay_values)
	end

	local chartfile, err = self:requireChartfile(user, remote, chartplay.hash)
	if not chartfile then
		return nil, err
	end

	local events_data, err = remote:getEventsData(chartplay.events_hash)
	if not events_data then
		return nil, err or "missing error"
	end

	if md5.sumhexa(events_data) ~= chartplay.events_hash then
		return nil, "invalid replay hash"
	end

	local ok, err = self.replaysStorage:set(chartplay.events_hash, events_data)
	if not ok then
		return nil, err
	end

	chartplay.submitted_at = os.time()
	self.charts_repo:updateChartplay(chartplay)

	if chartplay.custom then
		return chartplay
	end

	local cpcd, err = self.chartplayComputer:compute(chartplay)
	if not cpcd then
		-- if something custom-related then set custom = true
		-- if n/a or something else then compute_state = "invalid"
		return nil, err
	end

	chartplay.compute_state = "valid"

	local computed_chartplay, computed_chartdiff = cpcd[1], cpcd[2]

	if not chartplay:equalsComputed(computed_chartplay) then
		chartplay.custom = true
		self.charts_repo:updateChartplay(chartplay)
		-- client error?
		return nil, "computed values differs"
	end

	self.charts_repo:updateChartplay(chartplay)

	local chartdiff = self.charts_repo:getChartdiffByChartkey(computed_chartdiff)
	if not chartdiff then
		self.charts_repo:createChartdiff(computed_chartdiff)
	elseif not chartdiff:equalsComputed(computed_chartdiff) then
		computed_chartdiff.id = chartdiff.id
		self.charts_repo:updateChartdiff(computed_chartdiff)
		-- add a note on chartdiff page about this change
	end

	self.leaderboards:addChartplay(chartplay)

	return chartplay
end

return Chartplays
