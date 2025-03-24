local IChartsRepo = require("sea.chart.repos.IChartsRepo")

---@class sea.ChartsRepo: sea.IChartsRepo
---@operator call: sea.ChartsRepo
local ChartsRepo = IChartsRepo + {}

---@param models rdb.Models
function ChartsRepo:new(models)
	self.models = models
end

---@return sea.Chartfile[]
function ChartsRepo:getChartfiles()
	return self.models.chartfiles:select()
end

---@param hash string
---@return sea.Chartfile?
function ChartsRepo:getChartfileByHash(hash)
	return self.models.chartfiles:find({hash = assert(hash)})
end

---@param chartfile sea.Chartfile
---@return sea.Chartfile
function ChartsRepo:createChartfile(chartfile)
	return self.models.chartfiles:create(chartfile)
end

---@param chartfile sea.Chartfile
---@return sea.Chartfile
function ChartsRepo:updateChartfile(chartfile)
	return self.models.chartfiles:update(chartfile, {id = assert(chartfile.id)})[1]
end

--------------------------------------------------------------------------------

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

---@param id integer
---@return sea.Chartplay?
function ChartsRepo:getChartplay(id)
	return self.models.chartplays:find({id = assert(id)})
end

---@return sea.Chartplay[]
function ChartsRepo:getChartplays()
	return self.models.chartplays:select()
end

---@param events_hash string
---@return sea.Chartplay?
function ChartsRepo:getChartplayByEventsHash(events_hash)
	return self.models.chartplays:find({events_hash = assert(events_hash)})
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

return ChartsRepo
