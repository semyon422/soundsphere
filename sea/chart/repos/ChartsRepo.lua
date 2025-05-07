local IChartsRepo = require("sea.chart.repos.IChartsRepo")
local table_util = require("table_util")
local sql_util = require("rdb.sql_util")

---@class sea.ChartsRepo: sea.IChartsRepo
---@operator call: sea.ChartsRepo
local ChartsRepo = IChartsRepo + {}

---@param models rdb.Models
---@param diffcalc_fields string[]
function ChartsRepo:new(models, diffcalc_fields)
	self.models = models
	self.diffcalc_fields = diffcalc_fields
end

---@return sea.Chartdiff[]
function ChartsRepo:getChartdiffs()
	return self.models.chartdiffs:select()
end

---@param id number
---@return sea.Chartdiff?
function ChartsRepo:getChartdiff(id)
	return self.models.chartdiffs:find({id = assert(id)})
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

---@param hash string
---@param index number
---@return sea.Chartdiff?
function ChartsRepo:selectDefaultChartdiff(hash, index)
	return self.models.chartdiffs:find({
		hash = assert(hash),
		index = assert(index),
		modifiers = {},
		rate = 1,
		mode = "mania",
	})
end

---@return integer
function ChartsRepo:countChartdiffs()
	return self.models.chartdiffs:count()
end

function ChartsRepo:deleteChartdiffs()
	self.models.chartdiffs:delete()
end

function ChartsRepo:deleteModifiedChartdiffs()
	self.models.chartdiffs:delete({
		"or",
		modifiers__ne = {},
		rate__ne = 1,
	})
end

---@param id integer
---@return sea.Chartdiff?
function ChartsRepo:deleteChartdiff(id)
	return self.models.chartdiffs:delete({id = assert(id)})[1]
end

---@param hash string
---@param index integer
---@return sea.Chartdiff[]
function ChartsRepo:deleteChartdiffsByHashIndex(hash, index)
	return self.models.chartdiffs:delete({
		hash = assert(hash),
		index = assert(index),
	})
end

---@param chartdiff sea.Chartdiff
---@return sea.Chartdiff
function ChartsRepo:createUpdateChartdiff(chartdiff)
	local _chartdiff = self:getChartdiffByChartkey(chartdiff)
	if not _chartdiff then
		return self:createChartdiff(chartdiff)
	end
	chartdiff.id = _chartdiff.id
	return self:updateChartdiff(chartdiff)
end

---@return sea.Chartdiff[]
function ChartsRepo:getIncompleteChartdiffs()
	---@type rdb.Conditions
	local conds = {"or"}
	for _, field in ipairs(self.diffcalc_fields) do
		conds[field .. "__isnull"] = true
	end
	assert(next(conds))
	return self.models.chartdiffs:select(conds)
end

---@param field string
function ChartsRepo:resetDiffcalcField(field)
	assert(table_util.indexof(self.diffcalc_fields, field))
	self.models.chartdiffs:update({[field] = sql_util.NULL})
end

--------------------------------------------------------------------------------

---@return sea.Chartmeta[]
function ChartsRepo:getChartmetas()
	return self.models.chartmetas:select()
end

---@return sea.Chartmeta?
function ChartsRepo:getChartmeta(id)
	return self.models.chartmetas:find({id = assert(id)})
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

---@return integer
function ChartsRepo:countChartmetas()
	return self.models.chartmetas:count()
end

function ChartsRepo:deleteChartmetas()
	self.models.chartmetas:delete()
end

---@param format sea.ChartFormat
function ChartsRepo:deleteChartmetasByFormat(format)
	self.models.chartmetas:delete({
		format = assert(format),
	})
end

---@return sea.Chartmeta[]
function ChartsRepo:getChartmetasMissingChartdiffs()
	return self.models.chartmetas_diffs_missing:select()
end

---@param chartmeta sea.Chartmeta
---@return sea.Chartmeta
function ChartsRepo:createUpdateChartmeta(chartmeta)
	local _chartmeta = self:getChartmetaByHashIndex(chartmeta.hash, chartmeta.index)
	if not _chartmeta then
		return self:createChartmeta(chartmeta)
	end
	chartmeta.id = _chartmeta.id
	return self:updateChartmeta(chartmeta)
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
---@param state sea.ComputeState?
---@param limit integer?
---@return sea.Chartplay[]
function ChartsRepo:getChartplaysComputed(computed_at, state, limit)
	return self.models.chartplays:select({
		computed_at__lte = assert(computed_at),
		compute_state = state,
		compute_state__isnull = not state,
	}, {
		order = {"computed_at ASC"},
		limit = limit or 1,
	})
end

---@return sea.Chartplay[]
function ChartsRepo:getChartplaysComputedNull()
	return self.models.chartplays_computable:select({
		compute_state__isnull = true,
	})
end

---@param chartmeta_key sea.ChartmetaKey
---@return sea.Chartplay[]
function ChartsRepo:getChartplaysForChartmeta(chartmeta_key)
	return self.models.chartplays_list:select({
		hash = assert(chartmeta_key.hash),
		index = assert(chartmeta_key.index),
	})
end

---@param chartkey sea.Chartkey
---@return sea.Chartplay[]
function ChartsRepo:getChartplaysForChartdiff(chartkey)
	return self.models.chartplays_list:select({
		hash = assert(chartkey.hash),
		index = assert(chartkey.index),
		modifiers = assert(chartkey.modifiers),
		rate = assert(chartkey.rate),
		mode = assert(chartkey.mode),
	})
end

---@return sea.Chartplay[]
function ChartsRepo:getChartplaysMissingChartdiffs()
	return self.models.chartplays_list:select({
		chartdiff_id__isnull = true,
		chartmeta_id__isnotnull = true,
	})
end

return ChartsRepo
