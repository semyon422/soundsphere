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

---@return sea.Chartmeta[]
function IChartsRepo:getChartmetas()
	return {}
end

---@param hash string
---@param index integer
---@return sea.Chartmeta?
function IChartsRepo:getChartmetaByHashIndex(hash, index)
	return {}
end

---@param chartmeta sea.Chartmeta
---@return sea.Chartmeta
function IChartsRepo:createChartmeta(chartmeta)
	return chartmeta
end

---@param chartmeta sea.Chartmeta
---@return sea.Chartmeta
function IChartsRepo:updateChartmeta(chartmeta)
	return chartmeta
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

---@param replay_hash string
---@return sea.Chartplay?
function IChartsRepo:getChartplayByReplayHash(replay_hash)
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
