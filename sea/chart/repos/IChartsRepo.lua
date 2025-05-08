local class = require("class")

---@class sea.IChartsRepo
---@operator call: sea.IChartsRepo
local IChartsRepo = class()

---@return sea.Chartdiff[]
function IChartsRepo:getChartdiffs()
	return {}
end

---@param id number
---@return sea.Chartdiff?
function IChartsRepo:getChartdiff(id)
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

---@param hash string
---@param index number
---@return sea.Chartdiff?
function IChartsRepo:selectDefaultChartdiff(hash, index)
	return {}
end

---@return integer
function IChartsRepo:countChartdiffs()
	return 0
end

function IChartsRepo:deleteChartdiffs()
end

function IChartsRepo:deleteModifiedChartdiffs()
end

---@param id integer
---@return sea.Chartdiff?
function IChartsRepo:deleteChartdiff(id)
	return {}
end

---@param hash string
---@param index integer
---@return sea.Chartdiff[]
function IChartsRepo:deleteChartdiffsByHashIndex(hash, index)
	return {}
end

---@param chartdiff sea.Chartdiff
---@return sea.Chartdiff
function IChartsRepo:createUpdateChartdiff(chartdiff)
	return {}
end

---@return sea.Chartdiff[]
function IChartsRepo:getIncompleteChartdiffs()
	return {}
end

---@param field string
function IChartsRepo:resetDiffcalcField(field)
end

--------------------------------------------------------------------------------

---@return sea.Chartmeta[]
function IChartsRepo:getChartmetas()
	return {}
end

---@return sea.Chartmeta?
function IChartsRepo:getChartmeta(id)
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

---@return integer
function IChartsRepo:countChartmetas()
	return 0
end

function IChartsRepo:deleteChartmetas()
end

---@param format sea.ChartFormat
function IChartsRepo:deleteChartmetasByFormat(format)
end

---@return sea.Chartmeta[]
function IChartsRepo:getChartmetasMissingChartdiffs()
	return {}
end

---@param chartmeta sea.Chartmeta
---@return sea.Chartmeta
function IChartsRepo:createUpdateChartmeta(chartmeta)
	return {}
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

---@param computed_at integer
---@param state sea.ComputeState
---@return integer
function IChartsRepo:getChartplaysComputedCount(computed_at, state)
	return 0
end

---@param computed_at integer
---@param state sea.ComputeState
---@param limit integer?
---@return sea.Chartplay[]
function IChartsRepo:getChartplaysComputed(computed_at, state, limit)
	return {}
end

---@param chartmeta_key sea.ChartmetaKey
---@return sea.Chartplay[]
function IChartsRepo:getChartplaysForChartmeta(chartmeta_key)
	return {}
end

---@param chartkey sea.Chartkey
---@return sea.Chartplay[]
function IChartsRepo:getChartplaysForChartdiff(chartkey)
	return {}
end

---@return sea.Chartplay[]
function IChartsRepo:getChartplaysMissingChartdiffs()
	return {}
end

return IChartsRepo
