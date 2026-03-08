local class = require("class")
local ExpireTable = require("ExpireTable")
local Observable = require("Observable")
local path_util = require("path_util")

---@class rizu.select.stores.ListStore
---@operator call: rizu.select.stores.ListStore
local ListStore = class()

---@param library rizu.library.Library
function ListStore:new(library)
	self.library = library
	---@type rizu.library.LocatedChartview[]?
	self.items = nil -- If nil, use repo global index (Primary)
	self.itemsCount = 0
	self.onChanged = Observable()

	local cache = ExpireTable()
	self.cache = cache
	self.cache.load = function(_, k)
		return self:loadObject(k)
	end
end

---@param itemIndex number
---@return rizu.library.LocatedChartview
function ListStore:loadObject(itemIndex)
	if self.items then
		return self.items[itemIndex]
	end

	local chartviewsRepo = self.library.chartviewsRepo
	local _chartview = chartviewsRepo.chartviews[itemIndex - 1]
	local chartview = chartviewsRepo:getChartview(_chartview)
	if not chartview then
		return {}
	end

	---@cast chartview rizu.library.LocatedChartview
	chartview.lamp = _chartview.lamp
	return chartview
end

---@param items rizu.library.LocatedChartview[]?
---@param mode string?
function ListStore:updateItems(items, mode)
	self.items = items
	self.mode = mode

	if items then
		self.itemsCount = #items
		-- Populate paths for local items
		for _, chart in ipairs(items) do
			if chart.location_id and not chart.location_path then
				local location = self.library.locationsRepo:selectLocationById(chart.location_id)
				local prefix = self.library.locations:getPrefix(location)
				chart.location_prefix = prefix
				chart.location_dir = path_util.join(prefix, chart.dir)
				chart.location_path = path_util.join(prefix, chart.path)
				chart.real_dir = path_util.join(location.path, chart.dir)
				chart.real_path = path_util.join(location.path, chart.path)
			end
		end
	else
		self.itemsCount = self.library.chartviewsRepo.chartviews_count
	end

	self.cache:new()
	self.onChanged:send({count = self.itemsCount, items = self.items})
end

function ListStore:clear()
	self:updateItems({}, nil)
end

---@return number
function ListStore:count()
	return self.itemsCount
end

---@param i number
---@return rizu.library.LocatedChartview?
function ListStore:get(i)
	if i < 1 or i > self.itemsCount then
		return nil
	end
	return self.cache:get(i)
end

---@param chartview rizu.library.IChartviewBase
---@return number
function ListStore:indexof(chartview)
	if self.items then
		return self:_indexofLocal(chartview)
	end

	local cdb = self.library.chartviewsRepo
	return
		cdb.chartplay_id_to_global_index[chartview.chartplay_id] or
		cdb.chartdiff_id_to_global_index[chartview.chartdiff_id] or
		cdb.chartfile_id_to_global_index[chartview.chartfile_id] or
		cdb.set_id_to_global_index[chartview.chartfile_set_id] or
		1
end

---@param chartview rizu.library.IChartviewBase
---@return number
function ListStore:_indexofLocal(chartview)
	local chartfile_id = chartview.chartfile_id
	local chartmeta_id = chartview.chartmeta_id
	local chartdiff_id = chartview.chartdiff_id
	local chartplay_id = chartview.chartplay_id

	for i, chart in ipairs(self.items) do
		if chart.chartfile_id == chartfile_id and chart.chartdiff_id == chartdiff_id and chart.chartplay_id == chartplay_id then
			return i
		end
	end
	for i, chart in ipairs(self.items) do
		if chart.chartfile_id == chartfile_id and chart.chartdiff_id == chartdiff_id then
			return i
		end
	end
	for i, chart in ipairs(self.items) do
		if chart.chartfile_id == chartfile_id and chart.chartmeta_id == chartmeta_id then
			return i
		end
	end
	for i, chart in ipairs(self.items) do
		if chart.chartdiff_id == chartdiff_id then
			return i
		end
	end
	return 1
end

return ListStore
