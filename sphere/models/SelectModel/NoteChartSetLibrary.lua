local class = require("class")
local ExpireTable = require("ExpireTable")
local table_util = require("table_util")

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
	local cacheDatabase = self.cacheModel.cacheDatabase
	local _chartview = cacheDatabase.chartviews[itemIndex - 1]
	local chartview = cacheDatabase:getChartview(_chartview.chartfile_id, _chartview.chartmeta_id)
	if not chartview then
		return {}
	end
	chartview.lamp = _chartview.lamp
	return chartview
end

function NoteChartSetLibrary:updateItems()
	self.itemsCount = self.cacheModel.cacheDatabase.chartviews_count
	self.cache:new()
end

---@param chartview table
---@return number
function NoteChartSetLibrary:indexof(chartview)
	local chartfile_id = chartview.chartfile_id
	local chartmeta_id = chartview.chartmeta_id
	local set_id = chartview.chartfile_set_id

	local cdb = self.cacheModel.cacheDatabase
	local ids = cdb.id_to_global_offset
	return (ids[chartfile_id] and ids[chartfile_id][chartmeta_id] or
		cdb.set_id_to_global_offset[set_id] or 0) + 1
end

return NoteChartSetLibrary
