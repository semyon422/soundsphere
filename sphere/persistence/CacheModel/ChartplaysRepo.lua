local class = require("class")

---@class sphere.ChartplaysRepo
---@operator call: sphere.ChartplaysRepo
local ChartplaysRepo = class()

---@param gdb sphere.GameDatabase
function ChartplaysRepo:new(gdb)
	self.models = gdb.models
end

---@return sea.Chartplay[]
function ChartplaysRepo:getChartplays()
	return self.models.chartplays:select()
end

---@return sea.Chartplay[]
function ChartplaysRepo:getChartplaysNullComputeState()
	return self.models.chartplays:select({
		compute_state__isnull = true,
	})
end

---@param id number
---@return sea.Chartplay?
function ChartplaysRepo:getChartplay(id)
	return self.models.chartplays:find({id = assert(id)})
end

---@param chartplay sea.Chartplay
---@return sea.Chartplay
function ChartplaysRepo:createChartplay(chartplay)
	return self.models.chartplays:create(chartplay)
end

---@param chartplay table
---@return sea.Chartplay?
function ChartplaysRepo:updateChartplay(chartplay)
	return self.models.chartplays:update(chartplay, {id = assert(chartplay.id)})[1]
end

---@param replay_hash string
---@return sea.Chartplay?
function ChartplaysRepo:getChartplayByReplayHash(replay_hash)
	return self.models.chartplays:find({
		replay_hash = assert(replay_hash),
	})
end

---@param chartmeta_key sea.ChartmetaKey
---@return sea.Chartplay[]
function ChartplaysRepo:getChartplaysForChartmeta(chartmeta_key)
	return self.models.chartplays_list:select({
		hash = assert(chartmeta_key.hash),
		index = assert(chartmeta_key.index),
	})
end

---@param chartkey sea.Chartkey
---@return sea.Chartplay[]
function ChartplaysRepo:getChartplaysForChartdiff(chartkey)
	return self.models.chartplays_list:select({
		hash = assert(chartkey.hash),
		index = assert(chartkey.index),
		modifiers = assert(chartkey.modifiers),
		rate = assert(chartkey.rate),
		mode = assert(chartkey.mode),
	})
end

---@return sea.Chartplay[]
function ChartplaysRepo:getChartplaysWithMissingChartdiffs()
	return self.models.chartplays_list:select({
		chartdiff_id__isnull = true,
		chartmeta_id__isnotnull = true,
	})
end

return ChartplaysRepo
