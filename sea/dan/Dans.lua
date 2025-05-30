local class = require("class")
local dan_list = require("sea.dan.dan_list")

local DanClear = require("sea.dan.DanClear")

---@class sea.Dans
---@operator call: sea.Dans
---@field hashes {[string]: sea.Dan} The last chartmta hash is used as a key. We need the last chartmta for dans, where the charts are played separately.
local Dans = class()

---@param charts_repo sea.ChartsRepo
---@param dan_clears_repo sea.DanClearsRepo
function Dans:new(charts_repo, dan_clears_repo)
	self.charts_repo = charts_repo
	self.dan_clears_repo = dan_clears_repo
	self.hashes = {}

	for _, dan in pairs(dan_list) do
		local last_chartmeta = dan.chartmetas[#dan.chartmetas]
		self.hashes[last_chartmeta.hash] = dan
	end
end

---@param chartmeta_key sea.ChartmetaKey
---@return sea.Dan?
function Dans:findDan(chartmeta_key)
	return self.hashes[chartmeta_key.hash]
end

---@param chartmeta_key sea.ChartmetaKey
---@return boolean
function Dans:isDan(chartmeta_key)
	return self:findDan(chartmeta_key) ~= nil
end

---@param dan sea.Dan
---@param chartplay sea.Chartplay
---@return boolean ok
---@return string? err
local function isChartplayValid(dan, chartplay)
	if chartplay.pause_count ~= 0 then
		return false, "pauses are not allowed"
	end

	if chartplay.timings ~= dan.timings then
		return false, "unsuitable timings"
	end

	if chartplay.subtimings ~= dan.subtimings then
		return false, "unsuitable subtimings"
	end

	if chartplay.rate < 1 then
		return false, "rate less than 1 is not allowed"
	end

	if #chartplay.modifiers ~= 0 then
		return false, "modifiers are not allowed"
	end

	local co = chartplay.columns_order
	if co then
		local prev_column = co[1]

		for _, column in ipairs(co) do
			if math.abs(column - prev_column) > 1 then
				return false, "invalid column order"
			end
			prev_column = column
		end
	end

	return true
end

---@param dan sea.Dan
---@param chartplays sea.Chartplay[]
---@return boolean ok
---@return string? err
local function validateChartplays(dan, chartplays)
	if #chartplays ~= #dan.chartmetas then
		return false, "invalid chartplay order"
	end

	for i, chartmeta in ipairs(dan.chartmetas) do
		if chartplays[#chartplays - (i - 1)].hash ~= chartmeta.hash then
			return false, "invalid chartplay order"
		end
	end

	for _, cp in ipairs(chartplays) do
		local ok, err = isChartplayValid(dan, cp)
		if not ok then
			return false, err
		end

		if cp.rate ~= chartplays[1].rate then
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

	local ok, err = isChartplayValid(dan, chartplay)

	if not ok then
		return nil, err
	end

	local accuracy = chartplay:getNormAccuracy()
	local miss_count = chartplay.miss_count

	if #dan.chartmetas ~= 1 then
		local cps = self.charts_repo:getRecentChartplays(user.id, #dan.chartmetas)
		ok, err = validateChartplays(dan, cps)

		if not ok then
			return nil, err
		end

		accuracy = 0 ---@type number
		miss_count = 0 ---@type number

		for _, cp in ipairs(cps) do
			accuracy = accuracy + cp.accuracy * (1 / #cps)
			miss_count = miss_count + cp.miss_count
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
	dan_clear.chartplay_ids = {chartplay.id}
	dan_clear = self.dan_clears_repo:createDanClear(dan_clear)
	return dan_clear
end

return Dans
