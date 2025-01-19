local class = require("class")
local Chartplay = require("sea.chart.Chartplay")
local Chartfile = require("sea.chart.Chartfile")
local ChartplaysAccess = require("sea.chart.access.ChartplaysAccess")

---@class sea.Chartplays
---@operator call: sea.Chartplays
local Chartplays = class()

---@param chartplaysRepo sea.IChartplaysRepo
---@param chartfilesRepo sea.IChartfilesRepo
---@param clientPeers sea.ClientPeers
function Chartplays:new(chartplaysRepo, chartfilesRepo, clientPeers)
	self.chartplaysRepo = chartplaysRepo
	self.chartfilesRepo = chartfilesRepo
	self.chartplaysAccess = ChartplaysAccess()
	self.clientPeers = clientPeers
end

---@return sea.Chartplay[]
function Chartplays:getChartplays()
	return self.chartplaysRepo:getChartplays()
end

---@param user sea.User
---@param hash string
---@return sea.Chartfile?
---@return string?
function Chartplays:requireChartfile(user, hash)
	local chartfile = self.chartfilesRepo:getChartfileByHash(hash)
	if not chartfile then
		local chartfile_values = Chartfile()
		chartfile_values.hash = hash
		chartfile_values.creator_id = user.id
		chartfile = self.chartfilesRepo:createChartfile(chartfile_values)
	end

	local peer = assert(self.clientPeers:get(user.id))
	local ok, err = peer:requireChartfileData(hash)
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
---@param chartplay_values sea.Chartplay
---@return sea.Chartplay?
---@return string?
function Chartplays:submit(user, chartplay_values)
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

	local peer, err = self.clientPeers:get(user.id)
	if not peer then
		return nil, err
	end

	local chartfile, err = self:requireChartfile(user, chartplay.hash)
	if not chartfile then
		return nil, err
	end

	local ok, err = peer:requireEventsData(chartplay.events_hash)
	if not ok then
		return nil, err or "missing error"
	end

	chartplay = assert(self.chartplaysRepo:getChartplay(chartplay.id))
	if not chartplay.submitted_at then
		-- client error?
		return nil, "chartplay not submitted"
	end

	-- if is_valid_modifiers(chartplay.modifiers) then
	-- 	compute(chartplay, notes, events)
	-- 	validate(chartplay, chartplay_values)  -- should equal
	-- 	chartdiff.notes_hash = chartplay.notes_hash  -- notify if changed

	-- 	add_to_leaderboards(chartplay)
	-- 	chartplay.computed = true
	-- else
	-- 	-- custom mods
	-- 	chartplay.computed = false

	-- end

	return chartplay
end

---@param user sea.User
---@param chartplay sea.Chartplay
function Chartplays:compute(user, chartplay)
	---@type sea.Chartfile
	local chartfile = nil  -- get chartfile by hash
	if not chartfile then
		return nil, "not chartfile"
	end

	if chartfile.compute_state ~= "valid" then
		return nil, 'chartfile.compute_state ~= "valid"'
	end

	-- compute chartplay using chartfile


end

return Chartplays
