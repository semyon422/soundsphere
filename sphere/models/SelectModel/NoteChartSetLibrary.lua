local class = require("class")
local ExpireTable = require("ExpireTable")

---@class sphere.NoteChartSetLibrary
---@operator call: sphere.NoteChartSetLibrary
local NoteChartSetLibrary = class()

NoteChartSetLibrary.itemsCount = 0

---@param cacheModel sphere.CacheModel
function NoteChartSetLibrary:new(cacheModel)
	self.cacheModel = cacheModel

	local cache = ExpireTable()
	self.cache = cache
	self.cache.load = function(_, k)
		return self:loadObject(k)
	end

	self.items = newproxy(true)
	local mt = getmetatable(self.items)
	function mt.__index(_, i)
		if i < 1 or i > self.itemsCount then return end
		return cache:get(i)
	end
	function mt.__len()
		return self.itemsCount
	end
end

---@param itemIndex number
---@return table
function NoteChartSetLibrary:loadObject(itemIndex)
	local chartviewsRepo = self.cacheModel.chartviewsRepo
	local difftablesRepo = self.cacheModel.difftablesRepo

	local _chartview = chartviewsRepo.chartviews[itemIndex - 1]
	local chartview = chartviewsRepo:getChartview(_chartview)
	if not chartview then
		return {}
	end

	chartview.lamp = _chartview.lamp
	if chartview.hash and chartview.index then
		chartview.difftable_chartmetas = difftablesRepo:getDifftableChartmetasForChartmeta(chartview.hash, chartview.index)
	end

	return chartview
end

function NoteChartSetLibrary:updateItems()
	self.itemsCount = self.cacheModel.chartviewsRepo.chartviews_count
	self.cache:new()
end

---@param chartview table
---@return number
function NoteChartSetLibrary:indexof(chartview)
	local chartfile_id = chartview.chartfile_id
	local chartdiff_id = chartview.chartdiff_id
	local set_id = chartview.chartfile_set_id
	local chartplay_id = chartview.chartplay_id

	local cdb = self.cacheModel.chartviewsRepo
	return
		cdb.chartplay_id_to_global_index[chartplay_id] or
		cdb.chartdiff_id_to_global_index[chartdiff_id] or
		cdb.chartfile_id_to_global_index[chartfile_id] or
		cdb.set_id_to_global_index[set_id] or
		1
end

return NoteChartSetLibrary
