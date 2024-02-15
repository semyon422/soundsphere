local class = require("class")
local sql_util = require("rdb.sql_util")

---@class sphere.ChartRepo
---@operator call: sphere.ChartRepo
local ChartRepo = class()

---@param cdb sphere.ChartsDatabase
function ChartRepo:new(cdb)
	self.models = cdb.models
end

----------------------------------------------------------------

---@param dir string?
---@param name string
---@return table?
function ChartRepo:selectChartfileSet(dir, name)
	return self.models.chartfile_sets:find({
		dir = dir,
		dir__isnull = not dir,
		name = assert(name),
	})
end

---@param chartfile_set table
---@return table
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

---@param dir string?
---@return table
function ChartRepo:selectChartfileSetsAtPath(dir)
	return self.models.chartfile_sets:select({dir__startswith = dir})
end

---@return number
function ChartRepo:countChartfileSets(conds)
	return self.models.chartfile_sets:count(conds)
end

--------------------------------------------------------------------------------

---@param set_id number
---@param name string
---@return table?
function ChartRepo:selectChartfile(set_id, name)
	return self.models.chartfiles:find({set_id = assert(set_id), name = assert(name)})
end

---@param chartfile table
---@return table
function ChartRepo:insertChartfile(chartfile)
	return self.models.chartfiles:create(chartfile)
end

---@param chartfile table
function ChartRepo:updateChartfile(chartfile)
	self.models.chartfiles:update(chartfile, {id = assert(chartfile.id)})
end

---@param conds table?
function ChartRepo:resetChartfileHash(conds)
	self.models.chartfiles:update({hash = sql_util.NULL}, conds)
end

---@param conds table
function ChartRepo:deleteChartfiles(conds)
	self.models.chartfiles:delete(conds)
end

---@param path string?
---@param location_id number
---@return table
function ChartRepo:selectUnhashedChartfiles(path, location_id)
	return self.models.located_chartfiles:select({
		hash__isnull = true,
		path__startswith = path,
		location_id = assert(location_id),
	})
end

---@param id number
---@return table?
function ChartRepo:selectChartfileById(id)
	return self.models.chartfiles:find({id = assert(id)})
end

---@return number
function ChartRepo:countChartfiles(conds)
	return self.models.located_chartfiles:count(conds)
end

---@param hashes table
---@return rdb.ModelRow[]
function ChartRepo:getChartfilesByHashes(hashes)
	return self.models.chartfiles:select({hash__in = hashes})
end

--------------------------------------------------------------------------------

---@param chartmeta table
---@return table
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

---@return number
function ChartRepo:countChartmetas()
	return self.models.chartmetas:count()
end

---@param conds table
function ChartRepo:deleteChartmetas(conds)
	self.models.chartmetas:delete(conds)
end

--------------------------------------------------------------------------------

---@param chartdiff table
---@return table
function ChartRepo:insertChartdiff(chartdiff)
	return self.models.chartdiffs:create(chartdiff)
end

---@param chartdiff table
---@return table?
function ChartRepo:updateChartdiff(chartdiff)
	return self.models.chartdiffs:update(chartdiff, {id = assert(chartdiff.id)})[1]
end

---@param hash string
---@param index number
---@return table?
function ChartRepo:selectDefaultChartdiff(hash, index)
	return self.models.chartdiffs:find({
		hash = assert(hash),
		index = assert(index),
		modifiers = "",
		rate = 1,
	})
end

---@param chartdiff table
---@return table?
function ChartRepo:selectChartdiff(chartdiff)
	return self.models.chartdiffs:find({
		hash = assert(chartdiff.hash),
		index = assert(chartdiff.index),
		modifiers = assert(chartdiff.modifiers),
		rate = assert(chartdiff.rate),
	})
end

---@param id number
---@return table?
function ChartRepo:selectChartdiffById(id)
	return self.models.chartdiffs:find({id = assert(id)})
end

---@return number
function ChartRepo:countChartdiffs()
	return self.models.chartdiffs:count()
end

---@return table
function ChartRepo:selectAllScores()
	return self.models.scores:select()
end

---@param id number
---@return table?
function ChartRepo:selectScore(id)
	return self.models.scores:find({id = id})
end

---@param _score table
---@param chartdiff table
---@return table
function ChartRepo:insertScore(_score, chartdiff)
	local score = self.models.scores:create(_score)

	local scores = self:getScores(chartdiff.hash, chartdiff.index)
	self:calculateTopScore(scores)

	return score
end

---@param scores table
function ChartRepo:calculateTopScore(scores)
	table.sort(scores, function(a, b)
		return a.accuracy < b.accuracy
	end)
	for i, score in ipairs(scores) do
		if i == 1 and not score.is_top then
			self:updateScore({
				id = score.id,
				is_top = true,
			})
		elseif i > 1 and score.is_top then
			self:updateScore({
				id = score.id,
				is_top = false,
			})
		end
	end
end

---@param score table
---@return table?
function ChartRepo:updateScore(score)
	return self.models.scores:update(score, {id = score.id})
end

---@param hash string
---@param index number
---@return table
function ChartRepo:getScores(hash, index)
	return self.models.scores_list:select({
		hash = assert(hash),
		index = assert(index),
	})
end

---@return table
function ChartRepo:selectLocations()
	return self.models.locations:select()
end

---@param path string
---@return table?
function ChartRepo:selectLocation(path)
	return self.models.locations:find({path = assert(path)})
end

---@param id number
---@return table?
function ChartRepo:selectLocationById(id)
	return self.models.locations:find({id = assert(id)})
end

---@param location table
---@return table
function ChartRepo:insertLocation(location)
	return self.models.locations:create(location)
end

---@param location table
---@return table?
function ChartRepo:updateLocation(location)
	return self.models.locations:update(location, {id = location.id})
end

---@param location_id number
function ChartRepo:deleteLocation(location_id)
	self.models.locations:delete({id = assert(location_id)})
end

return ChartRepo
