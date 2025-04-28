local IChartsRepo = require("sea.chart.repos.IChartsRepo")

---@class sea.ChartsRepo: sea.IChartsRepo
---@operator call: sea.ChartsRepo
local ChartsRepo = IChartsRepo + {}

---@param models rdb.Models
function ChartsRepo:new(models)
	self.models = models
end

---@return sea.Chartdiff[]
function ChartsRepo:getChartdiffs()
	return self.models.chartdiffs:select()
end

---@param chartkey sea.Chartkey
---@return sea.Chartdiff?
function ChartsRepo:getChartdiffByChartkey(chartkey)
	return self.models.chartdiffs:find({
		hash = assert(chartkey.hash),
		index = assert(chartkey.index),
		modifiers = assert(chartkey.modifiers),
		rate = assert(chartkey.rate),
		mode = assert(chartkey.mode),
	})
end

---@param chartdiff sea.Chartdiff
---@return sea.Chartdiff
function ChartsRepo:createChartdiff(chartdiff)
	return self.models.chartdiffs:create(chartdiff)
end

---@param chartdiff sea.Chartdiff
---@return sea.Chartdiff
function ChartsRepo:updateChartdiff(chartdiff)
	return self.models.chartdiffs:update(chartdiff, {id = assert(chartdiff.id)})[1]
end

--------------------------------------------------------------------------------

---@return sea.Chartmeta[]
function ChartsRepo:getChartmetas()
	return self.models.chartmetas:select()
end

---@param hash string
---@param index integer
---@return sea.Chartmeta?
function ChartsRepo:getChartmetaByHashIndex(hash, index)
	return self.models.chartmetas:find({
		hash = assert(hash),
		index = assert(index),
	})
end

---@param chartmeta sea.Chartmeta
---@return sea.Chartmeta
function ChartsRepo:createChartmeta(chartmeta)
	return self.models.chartmetas:create(chartmeta)
end

---@param chartmeta sea.Chartmeta
---@return sea.Chartmeta
function ChartsRepo:updateChartmeta(chartmeta)
	return self.models.chartmetas:update(chartmeta, {id = assert(chartmeta.id)})[1]
end

--------------------------------------------------------------------------------

---@param id integer
---@return sea.Chartplay?
function ChartsRepo:getChartplay(id)
	return self.models.chartplays:find({id = assert(id)})
end

---@return sea.Chartplay[]
function ChartsRepo:getChartplays()
	return self.models.chartplays:select()
end

---@param replay_hash string
---@return sea.Chartplay?
function ChartsRepo:getChartplayByReplayHash(replay_hash)
	return self.models.chartplays:find({replay_hash = assert(replay_hash)})
end

---@param chartplay sea.Chartplay
---@return sea.Chartplay
function ChartsRepo:createChartplay(chartplay)
	return self.models.chartplays:create(chartplay)
end

---@param chartplay sea.Chartplay
---@return sea.Chartplay
function ChartsRepo:updateChartplay(chartplay)
	return self.models.chartplays:update(chartplay, {id = assert(chartplay.id)})[1]
end

---@param computed_at integer
---@param state sea.ComputeState
---@return integer
function ChartsRepo:getChartplaysComputedCount(computed_at, state)
	return self.models.chartplays:count({
		computed_at__lte = assert(computed_at),
		compute_state = assert(state),
	})
end

---@param computed_at integer
---@param state sea.ComputeState
---@param limit integer?
---@return sea.Chartplay[]
function ChartsRepo:getChartplaysComputed(computed_at, state, limit)
	return self.models.chartplays:select({
		computed_at__lte = assert(computed_at),
		compute_state = assert(state),
	}, {
		order = {"computed_at ASC"},
		limit = limit or 1,
	})
end

return ChartsRepo
