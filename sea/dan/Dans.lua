local class = require("class")
local dan_list = require("sea.dan.dan_list")

local DanClear = require("sea.dan.DanClear")

---@class sea.Dans
---@operator call: sea.Dans
---@field hashes {[string]: sea.Dan} The last chartdiff hash is used as a key. We need the last chartdiff for dans, where the charts are played separately.
local Dans = class()

---@param dan_clears_repo sea.DanClearsRepo
function Dans:new(dan_clears_repo)
	self.dan_clears_repo = dan_clears_repo
	self.hashes = {}

	for _, dan in pairs(dan_list) do
		local last_chartdiff = dan.chartdiffs[#dan.chartdiffs]
		self.hashes[last_chartdiff.hash] = dan
	end
end

---@param chartdiff_key sea.ChartdiffKey
---@return sea.Dan?
function Dans:findDan(chartdiff_key)
	return self.hashes[chartdiff_key.hash]
end

---@param chartdiff_key sea.ChartdiffKey
---@return boolean
function Dans:isDan(chartdiff_key)
	return self:findDan(chartdiff_key) ~= nil
end

---@param user sea.User
---@param chartplay sea.Chartplay
---@param chartdiff sea.Chartdiff
---@param time number
---@return sea.DanClear?
---@return string? err
function Dans:submit(user, chartplay, chartdiff, time)
	local dan = self:findDan(chartdiff)
	if not dan then
		return nil, "not a dan"
	end

	if chartplay.pause_count ~= 0 then
		return nil, "pauses are not allowed"
	end

	if chartplay.timings ~= dan.timings then
		return nil, "unsuitable timings"
	end

	if chartplay.rate < 1 then
		return nil, "rate less than 1 is not allowed"
	end

	local accuracy = chartplay:getNormAccuracy()

	if dan.min_accuracy and accuracy < dan.min_accuracy then
		return nil, "not cleared"
	end

	if dan.max_misses and chartplay.miss_count > dan.max_misses then
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
