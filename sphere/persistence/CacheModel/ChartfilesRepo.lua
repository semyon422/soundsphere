local class = require("class")
local sql_util = require("rdb.sql_util")

---@class sphere.ChartfilesRepo
---@operator call: sphere.ChartfilesRepo
local ChartfilesRepo = class()

---@param gdb sphere.GameDatabase
function ChartfilesRepo:new(gdb)
	self.models = gdb.models
end

--------------------------------------------------------------------------------

---@param dir string?
---@param name string
---@param location_id number
---@return table?
function ChartfilesRepo:selectChartfileSet(dir, name, location_id)
	return self.models.chartfile_sets:find({
		dir = dir,
		dir__isnull = not dir,
		name = assert(name),
		location_id = assert(location_id),
	})
end

---@param chartfile_set table
---@return table
function ChartfilesRepo:insertChartfileSet(chartfile_set)
	return self.models.chartfile_sets:create(chartfile_set)
end

---@param chartfile_set table
function ChartfilesRepo:updateChartfileSet(chartfile_set)
	self.models.chartfile_sets:update(chartfile_set, {id = assert(chartfile_set.id)})
end

---@param conds table
function ChartfilesRepo:deleteChartfileSets(conds)
	self.models.chartfile_sets:delete(conds)
end

---@param id number
---@return table?
function ChartfilesRepo:selectChartfileSetById(id)
	return self.models.chartfile_sets:find({id = assert(id)})
end

---@param location_id number?
---@return table
function ChartfilesRepo:selectChartfileSetsAtLocation(location_id)
	return self.models.chartfile_sets:select({location_id = location_id})
end

---@return number
function ChartfilesRepo:countChartfileSets(conds)
	return self.models.chartfile_sets:count(conds)
end

--------------------------------------------------------------------------------

---@param set_id number
---@param name string
---@return table?
function ChartfilesRepo:selectChartfile(set_id, name)
	return self.models.chartfiles:find({set_id = assert(set_id), name = assert(name)})
end

---@param chartfile table
---@return table
function ChartfilesRepo:insertChartfile(chartfile)
	return self.models.chartfiles:create(chartfile)
end

---@param chartfile table
function ChartfilesRepo:updateChartfile(chartfile)
	self.models.chartfiles:update(chartfile, {id = assert(chartfile.id)})
end

---@param conds table?
function ChartfilesRepo:resetChartfileHash(conds)
	self.models.chartfiles:update({hash = sql_util.NULL}, conds)
end

---@param conds table
function ChartfilesRepo:deleteChartfiles(conds)
	self.models.chartfiles:delete(conds)
end

---@param path string?
---@param location_id number
---@param set_id number?
---@return table
function ChartfilesRepo:selectUnhashedChartfiles(path, location_id, set_id)
	assert(not (path and set_id))
	return self.models.located_chartfiles:select({
		{"or", hash__isnull = true, chartmeta_id__isnull = true},
		set_id = set_id,
		set_dir__startswith = path,
		location_id = assert(location_id),
	})
end

---@param id number
---@return table?
function ChartfilesRepo:selectChartfileById(id)
	return self.models.chartfiles:find({id = assert(id)})
end

---@param hash string
---@return table?
function ChartfilesRepo:selectChartfileByHash(hash)
	return self.models.located_chartfiles:find({hash = assert(hash)})
end

---@return number
function ChartfilesRepo:countChartfiles(conds)
	return self.models.located_chartfiles:count(conds)
end

---@param hashes table
---@return rdb.ModelRow[]
function ChartfilesRepo:getChartfilesByHashes(hashes)
	return self.models.chartfiles:select({hash__in = hashes})
end

return ChartfilesRepo
