local class = require("class")
local ExpireTable = require("ExpireTable")
local Observable = require("Observable")

---@class rizu.select.stores.ChartSetStore
---@operator call: rizu.select.stores.ChartSetStore
local ChartSetStore = class()

---@param library rizu.library.Library
function ChartSetStore:new(library)
	self.library = library
	self.itemsCount = 0
	self.onChanged = Observable()

	local cache = ExpireTable()
	self.cache = cache
	self.cache.load = function(_, k)
		return self:loadObject(k)
	end
end

function ChartSetStore:__index(k)
	if type(k) == "number" then
		return self:get(k)
	end
	return ChartSetStore[k]
end

---@param itemIndex number
---@return rizu.LocatedChartview
function ChartSetStore:loadObject(itemIndex)
	local chartviewsRepo = self.library.chartviewsRepo

	local _chartview = chartviewsRepo.chartviews[itemIndex - 1]
	local chartview = chartviewsRepo:getChartview(_chartview)
	if not chartview then
		return {}
	end

	---@cast chartview rizu.LocatedChartview

	chartview.lamp = _chartview.lamp

	return chartview
end

function ChartSetStore:updateItems()
	self.itemsCount = self.library.chartviewsRepo.chartviews_count
	self.cache:new()
	self.onChanged:send({count = self.itemsCount})
end

---@return number
function ChartSetStore:count()
	return self.itemsCount
end

---@param i number
---@return rizu.LocatedChartview?
function ChartSetStore:get(i)
	if i < 1 or i > self.itemsCount then
		return nil
	end
	return self.cache:get(i)
end

---@param chartview rizu.IChartviewBase
---@return number
function ChartSetStore:indexof(chartview)
	local chartfile_id = chartview.chartfile_id
	local chartdiff_id = chartview.chartdiff_id
	local set_id = chartview.chartfile_set_id
	local chartplay_id = chartview.chartplay_id

	local cdb = self.library.chartviewsRepo
	return
		cdb.chartplay_id_to_global_index[chartplay_id] or
		cdb.chartdiff_id_to_global_index[chartdiff_id] or
		cdb.chartfile_id_to_global_index[chartfile_id] or
		cdb.set_id_to_global_index[set_id] or
		1
end

return ChartSetStore
