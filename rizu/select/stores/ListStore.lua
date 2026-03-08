local class = require("class")
local ExpireTable = require("ExpireTable")
local Observable = require("Observable")

---@class rizu.select.stores.ListStore
---@operator call: rizu.select.stores.ListStore
local ListStore = class()

---@param library rizu.library.Library
function ListStore:new(library)
	self.library = library
	self.onChanged = Observable()

	---@type cdata?
	self.items = nil
	self.itemsCount = 0
	self.maps = {}

	local cache = ExpireTable()
	self.cache = cache
	self.cache.load = function(_, k)
		return self:_loadObject(k)
	end
end

---@param result table?
function ListStore:setResult(result)
	if not result then
		self.items = nil
		self.itemsCount = 0
		self.maps = {}
	else
		self.items, self.itemsCount, self.maps = self.library.chartviewsRepo:unpackResult(result)
	end

	self.cache:new()
	self.onChanged:send({count = self.itemsCount})
end

---@private
---@param index number
---@return rizu.library.LocatedChartview?
function ListStore:_loadObject(index)
	if not self.items or index < 1 or index > self.itemsCount then
		return nil
	end

	local _chartview = self.items[index - 1]
	local chartview = self.library.chartviewsRepo:getChartview(_chartview)
	if not chartview then
		return nil
	end

	---@cast chartview rizu.library.LocatedChartview
	chartview.lamp = _chartview.lamp
	self.library:enrichChartview(chartview)
	return chartview
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
	local maps = self.maps
	local id

	id = chartview.chartplay_id
	if id and id ~= 0 and maps.chartplay_id_to_global_index[id] then
		return maps.chartplay_id_to_global_index[id]
	end

	id = chartview.chartdiff_id
	if id and id ~= 0 and maps.chartdiff_id_to_global_index[id] then
		return maps.chartdiff_id_to_global_index[id]
	end

	id = chartview.chartmeta_id
	if id and id ~= 0 and maps.chartmeta_id_to_global_index[id] then
		return maps.chartmeta_id_to_global_index[id]
	end

	id = chartview.chartfile_id
	if id and id ~= 0 and maps.chartfile_id_to_global_index[id] then
		return maps.chartfile_id_to_global_index[id]
	end

	id = chartview.chartfile_set_id
	if id and id ~= 0 and maps.set_id_to_global_index[id] then
		return maps.set_id_to_global_index[id]
	end

	return 1
end

return ListStore
