local class = require("class")
local dan_list = require("sea.dan.dan_list")

local ColumnOrder = require("sea.chart.ColumnsOrder")
local DanClear = require("sea.dan.DanClear")

---@class sea.Dans
---@operator call: sea.Dans
---@field hashes {[string]: {[integer]: sea.Dan}} The last chartmta hash is used as a key. We need the last chartmta for dans, where the charts are played separately.
local Dans = class()

---@param charts_repo sea.ChartsRepo
---@param dan_clears_repo sea.DanClearsRepo
function Dans:new(charts_repo, dan_clears_repo)
	self.charts_repo = charts_repo
	self.dan_clears_repo = dan_clears_repo
	self.hashes = {}

	for _, dan in pairs(dan_list) do
		local last_chartmeta = dan.chartmeta_keys[#dan.chartmeta_keys]
		self.hashes[last_chartmeta.hash] = self.hashes[last_chartmeta.hash] or {}
		self.hashes[last_chartmeta.hash][last_chartmeta.index] = dan
	end
end

---@param chartmeta_key sea.ChartmetaKey
---@return sea.Dan?
function Dans:findDan(chartmeta_key)
	local hash = self.hashes[chartmeta_key.hash]
	return hash and hash[chartmeta_key.index]
end

---@param chartmeta_key sea.ChartmetaKey
---@return boolean
function Dans:isDan(chartmeta_key)
	return self:findDan(chartmeta_key) ~= nil
end

---@param chartplay sea.Chartplay
---@param chartmeta sea.Chartmeta
---@return boolean ok
---@return string? err
local function isChartplayValid(chartplay, chartmeta)
	if chartplay.pause_count ~= 0 then
		return false, "pauses are not allowed"
	end

	if chartplay.timings and chartplay.timings ~= chartmeta.timings then
		return false, "unsuitable timings"
	end

	if chartplay.rate < 1 then
		return false, "rate less than 1 is not allowed"
	end

	if #chartplay.modifiers ~= 0 then
		return false, "modifiers are not allowed"
	end

	local column_order = ColumnOrder(chartmeta.inputmode, chartplay.columns_order)
	local order_name = column_order:getName()
	if order_name and order_name ~= "mirror" then
		return false, "invalid column order"
	end

	return true
end

---@param dan sea.Dan
---@param chartplays sea.Chartplay[]
---@param chartmetas sea.Chartmeta[]
---@return boolean ok
---@return string? err
local function validateChartplays(dan, chartplays, chartmetas)
	if #chartplays ~= #dan.chartmeta_keys then
		return false, "invalid chartplay order"
	end

	for i, dan_cmk in ipairs(dan.chartmeta_keys) do
		if chartplays[i].hash ~= dan_cmk.hash then
			return false, "invalid chartplay order"
		end
	end

	for i, chartplay in ipairs(chartplays) do
		local chartmeta = chartmetas[i]
		assert(chartmeta, #chartmetas)
		local ok, err = isChartplayValid(chartplay, chartmeta)
		if not ok then
			return false, err
		end

		if chartplay.rate ~= chartplays[1].rate then
			return false, "different rates in chartplays"
		end
	end

	return true
end

---@param user sea.User
---@param chartplay sea.Chartplay
---@param chartmeta_key sea.ChartmetaKey
---@param time number
---@return sea.DanClear?
---@return string? err
function Dans:submit(user, chartplay, chartmeta_key, time)
	local dan = self:findDan(chartmeta_key)
	if not dan then
		return nil, "not a dan"
	end

	local accuracy = 0
	local miss_count = 0
	local chartplay_ids = {}

	if #dan.chartmeta_keys == 1 then
		local chartmeta = self.charts_repo:getChartmetaByHashIndex(chartmeta_key.hash, chartmeta_key.index)
		if not chartmeta then
			return nil, "no chartmeta"
		end

		local ok, err = isChartplayValid(chartplay, chartmeta)
		if not ok then
			return nil, err
		end

		accuracy = chartplay:getNormAccuracy()
		miss_count = chartplay.miss_count
		table.insert(chartplay_ids, chartplay.id)
	else
		local chartplays = self.charts_repo:getRecentChartplays(user.id, #dan.chartmeta_keys)

		-- chartplays are in descening order, reversing the order to match chartmetas from a dan
		---@type sea.Chartplay[]
		local t = {}
		for i = #chartplays, 1, -1 do
			table.insert(t, chartplays[i])
		end
		chartplays = t

		local chartmetas = {}
		for _, cp in ipairs(chartplays) do
			local chartmeta = self.charts_repo:getChartmetaByHashIndex(cp.hash, cp.index)
			if not chartmeta then
				return nil, "no chartmeta"
			end
			table.insert(chartmetas, chartmeta)
		end

		local ok, err = validateChartplays(dan, chartplays, chartmetas)
		if not ok then
			return nil, err
		end

		for _, cp in ipairs(chartplays) do
			accuracy = accuracy + cp.accuracy * (1 / #chartplays)
			miss_count = miss_count + cp.miss_count
			table.insert(chartplay_ids, cp.id)
		end
	end

	if dan.min_accuracy and accuracy < dan.min_accuracy then
		return nil, "not cleared"
	end

	if dan.max_misses and miss_count > dan.max_misses then
		return nil, "not cleared"
	end

	local prev_dan_clear = self.dan_clears_repo:getUserDanClear(user.id, dan.id)

	if prev_dan_clear and prev_dan_clear.rate == chartplay.rate then
		return nil, "already cleared"
	end

	local dan_clear = DanClear()
	dan_clear.dan_id = dan.id
	dan_clear.user_id = user.id
	dan_clear.time = time
	dan_clear.rate = chartplay.rate
	dan_clear.chartplay_ids = chartplay_ids
	dan_clear = self.dan_clears_repo:createDanClear(dan_clear)
	return dan_clear
end

---@param user sea.User
---@return sea.DanClear[]
function Dans:getUserDanClears(user)
	return self.dan_clears_repo:getUserDanClears(user.id)
end

return Dans
