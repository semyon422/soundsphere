local class = require("class")
local Chartplay = require("sea.chart.Chartplay")
local Chartfile = require("sea.chart.Chartfile")
local ChartplaysAccess = require("sea.chart.access.ChartplaysAccess")

---@class sea.Chartplays
---@operator call: sea.Chartplays
local Chartplays = class()

---@param chartplaysRepo sea.IChartplaysRepo
---@param chartfilesRepo sea.IChartfilesRepo
---@param chartdiffsRepo sea.IChartdiffsRepo
---@param chartplayComputer sea.IChartplayComputer
---@param leaderboards sea.Leaderboards
function Chartplays:new(
	chartplaysRepo,
	chartfilesRepo,
	chartdiffsRepo,
	chartplayComputer,
	leaderboards
)
	self.chartplaysRepo = chartplaysRepo
	self.chartfilesRepo = chartfilesRepo
	self.chartdiffsRepo = chartdiffsRepo
	self.chartplayComputer = chartplayComputer
	self.leaderboards = leaderboards
	self.chartplaysAccess = ChartplaysAccess()
end

---@return sea.Chartplay[]
function Chartplays:getChartplays()
	return self.chartplaysRepo:getChartplays()
end

---@param user sea.User
---@param remote sea.ISubmissionClientRemote
---@param hash string
---@return sea.Chartfile?
---@return string?
function Chartplays:requireChartfile(user, remote, hash)
	local chartfile = self.chartfilesRepo:getChartfileByHash(hash)
	if not chartfile then
		local chartfile_values = Chartfile()
		chartfile_values.hash = hash
		chartfile_values.creator_id = user.id
		chartfile = self.chartfilesRepo:createChartfile(chartfile_values)
	end

	local ok, err = remote:requireChartfileData(hash)
	if not ok then
		return nil, err or "missing error"
	end

	chartfile = assert(self.chartfilesRepo:getChartfileByHash(hash))
	if not chartfile.submitted_at then
		-- client error?
		return nil, "chartfile not submitted"
	end

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

	local chartplay = self.chartplaysRepo:getChartplayByEventsHash(chartplay_values.events_hash)
	if not chartplay then
		chartplay_values.id = nil
		chartplay_values.user_id = user.id
		chartplay_values.created_at = os.time()

		chartplay = self.chartplaysRepo:createChartplay(chartplay_values)
	end

	local chartfile, err = self:requireChartfile(user, remote, chartplay.hash)
	if not chartfile then
		return nil, err
	end

	local ok, err = remote:requireEventsData(chartplay.events_hash)
	if not ok then
		return nil, err or "missing error"
	end

	chartplay = assert(self.chartplaysRepo:getChartplay(chartplay.id))
	if not chartplay.submitted_at then
		-- client error?
		return nil, "chartplay not submitted"
	end

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
		self.chartplaysRepo:updateChartplay(chartplay)
		-- client error?
		return nil, "computed values differs"
	end

	self.chartplaysRepo:updateChartplay(chartplay)

	local chartdiff = self.chartdiffsRepo:getChartdiffByChartkey(computed_chartdiff)
	if not chartdiff then
		self.chartdiffsRepo:createChartdiff(computed_chartdiff)
	elseif not chartdiff:equalsComputed(computed_chartdiff) then
		computed_chartdiff.id = chartdiff.id
		self.chartdiffsRepo:updateChartdiff(computed_chartdiff)
		-- add a note on chartdiff page about this change
	end

	self.leaderboards:addChartplay(chartplay)

	return chartplay
end

return Chartplays
