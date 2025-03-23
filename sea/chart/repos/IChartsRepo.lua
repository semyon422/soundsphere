local class = require("class")

---@class sea.IChartsRepo
---@operator call: sea.IChartsRepo
local IChartsRepo = class()

---@return sea.Chartfile[]
function IChartsRepo:getChartfiles()
	return {}
end

---@param hash string
---@return sea.Chartfile?
function IChartsRepo:getChartfileByHash(hash)
	return {}
end

---@param chartfile sea.Chartfile
---@return sea.Chartfile
function IChartsRepo:createChartfile(chartfile)
	return chartfile
end

---@param chartfile sea.Chartfile
---@return sea.Chartfile
function IChartsRepo:updateChartfile(chartfile)
	return chartfile
end

--------------------------------------------------------------------------------

---@return sea.Chartdiff[]
function IChartsRepo:getChartdiffs()
	return {}
end

---@param chartkey sea.Chartkey
---@return sea.Chartdiff?
function IChartsRepo:getChartdiffByChartkey(chartkey)
	return {}
end

---@param chartdiff sea.Chartdiff
---@return sea.Chartdiff
function IChartsRepo:createChartdiff(chartdiff)
	return chartdiff
end

---@param chartdiff sea.Chartdiff
---@return sea.Chartdiff
function IChartsRepo:updateChartdiff(chartdiff)
	return chartdiff
end

--------------------------------------------------------------------------------

---@return sea.Chartplay[]
function IChartsRepo:getChartplays()
	return {}
end

---@param id integer
---@return sea.Chartplay?
function IChartsRepo:getChartplay(id)
	return {}
end

---@param events_hash string
---@return sea.Chartplay?
function IChartsRepo:getChartplayByEventsHash(events_hash)
	return {}
end

---@param chartplay sea.Chartplay
---@return sea.Chartplay
function IChartsRepo:createChartplay(chartplay)
	return chartplay
end

---@param chartplay sea.Chartplay
---@return sea.Chartplay
function IChartsRepo:updateChartplay(chartplay)
	return chartplay
end

return IChartsRepo
