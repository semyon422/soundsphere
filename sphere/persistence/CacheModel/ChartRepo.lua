local class = require("class")

---@class sphere.ChartRepo
---@operator call: sphere.ChartRepo
local ChartRepo = class()

---@param cdb sphere.ChartsDatabase
function ChartRepo:new(cdb)
	self.models = cdb.models
end

----------------------------------------------------------------

---@param dir string
---@param name string
---@return table?
function ChartRepo:selectChartfileSet(dir, name)
	return self.models.chartfile_sets:find({dir = assert(dir), name = assert(name)})
end

---@param chartfile_set table
---@return table?
function ChartRepo:insertChartfileSet(chartfile_set)
	return self.models.chartfile_sets:create(chartfile_set)
end

---@param chartfile_set table
function ChartRepo:updateChartfileSet(chartfile_set)
	self.models.chartfile_sets:update(chartfile_set, {id = assert(chartfile_set.id)})
end

---@param conds table
function ChartRepo:deleteChartfileSets(conds)
	self.models.chartfile_sets:delete(conds)
end

---@param id number
---@return table?
function ChartRepo:selectChartfileSetById(id)
	return self.models.chartfile_sets:find({id = assert(id)})
end

---@param dir string
---@return table
function ChartRepo:selectChartfileSetsAtPath(dir)
	return self.models.chartfile_sets:select({dir__startswith = dir})
end

--------------------------------------------------------------------------------

---@param dir string
---@param name string
---@return table?
function ChartRepo:selectChartfile(dir, name)
	return self.models.chartfiles:find({dir = assert(dir), name = assert(name)})
end

---@param chartfile table
---@return table?
function ChartRepo:insertChartfile(chartfile)
	return self.models.chartfiles:create(chartfile)
end

---@param chartfile table
function ChartRepo:updateChartfile(chartfile)
	self.models.chartfiles:update(chartfile, {id = assert(chartfile.id)})
end

---@param conds table
function ChartRepo:deleteChartfiles(conds)
	self.models.chartfiles:delete(conds)
end

---@return table
function ChartRepo:selectUnhashedChartfiles()
	return self.models.chartfiles:select({hash__isnull = true})
end

---@param id number
---@return table?
function ChartRepo:selectChartfileById(id)
	return self.models.chartfiles:find({id = assert(id)})
end

-- ---@param setId number
-- ---@return rdb.ModelRow[]
-- function ChartRepo:getNoteChartsAtSet(setId)
-- 	return self.models.noteCharts:select({setId = setId})
-- end

-- ---@param hashes table
-- ---@return rdb.ModelRow[]
-- function ChartRepo:getNoteChartsByHashes(hashes)
-- 	return self.models.noteCharts:select({hash__in = hashes})
-- end

--------------------------------------------------------------------------------

---@param chartmeta table
---@return table?
function ChartRepo:insertChartmeta(chartmeta)
	return self.models.chartmetas:create(chartmeta)
end

---@param chartmeta table
function ChartRepo:updateChartmeta(chartmeta)
	self.models.chartmetas:update(chartmeta, {id = assert(chartmeta.id)})
end

---@param hash string
---@param index number
---@return table?
function ChartRepo:selectChartmeta(hash, index)
	return self.models.chartmetas:find({hash = assert(hash), index = assert(index)})
end

---@param id number
---@return table?
function ChartRepo:selectChartmetaById(id)
	return self.models.chartmetas:find({id = assert(id)})
end

--------------------------------------------------------------------------------

---@param chartdiff table
---@return table?
function ChartRepo:insertChartdiff(chartdiff)
	return self.models.chartdiffs:create(chartdiff)
end

---@param chartdiff table
function ChartRepo:updateChartdiff(chartdiff)
	self.models.chartdiffs:update(chartdiff, {id = assert(chartdiff.id)})
end

---@param hash string
---@param index number
---@return table?
function ChartRepo:selectChartdiff(hash, index)
	return self.models.chartdiffs:find({
		hash = assert(hash),
		index = assert(index),
		play_config_id__isnull = true,
	})
end

---@param id number
---@return table?
function ChartRepo:selectChartdiffById(id)
	return self.models.chartdiffs:find({id = assert(id)})
end

return ChartRepo
