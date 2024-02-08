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
	local entry = cacheDatabase.noteChartSetItems[itemIndex - 1]
	local item = cacheDatabase:getNoteChartSetItem(entry.chartfile_id, entry.chartmeta_id)
	item.lamp = entry.lamp
	return item
end

function NoteChartSetLibrary:updateItems()
	self.itemsCount = self.cacheModel.cacheDatabase.noteChartSetItemsCount
	self.cache:new()
end

---@param chartfile_id number?
---@param chartmeta_id number?
---@param noteChartSetId number?
---@return number
function NoteChartSetLibrary:getItemIndex(chartfile_id, chartmeta_id, noteChartSetId)
	local cdb = self.cacheModel.cacheDatabase
	local ids = cdb.id_to_global_offset
	return (ids[chartfile_id] and ids[chartfile_id][chartmeta_id] or
		cdb.set_id_to_global_offset[noteChartSetId] or 0) + 1
end

return NoteChartSetLibrary
