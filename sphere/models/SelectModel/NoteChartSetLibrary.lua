local class = require("class")
local ExpireTable = require("ExpireTable")
local table_util = require("table_util")

---@class sphere.NoteChartSetLibrary
---@operator call: sphere.NoteChartSetLibrary
local NoteChartSetLibrary = class()

NoteChartSetLibrary.itemsCount = 0

function NoteChartSetLibrary:new()
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
	local chartRepo = self.cacheModel.chartRepo
	local entry = self.cacheModel.cacheDatabase.noteChartSetItems[itemIndex - 1]
	local noteChart = chartRepo:selectNoteChartEntryById(entry.noteChartId)
	local noteChartData = chartRepo:selectNoteChartDataEntryById(entry.noteChartDataId)

	local item = {
		noteChartDataId = entry.noteChartDataId,
		noteChartId = entry.noteChartId,
		setId = entry.setId,
		lamp = entry.lamp,
		itemIndex = itemIndex,
	}

	table_util.copy(noteChart, item)
	table_util.copy(noteChartData, item)

	return item
end

function NoteChartSetLibrary:updateItems()
	self.itemsCount = self.cacheModel.cacheDatabase.noteChartSetItemsCount
	self.cache:new()
end

---@param noteChartId number?
---@param noteChartDataId number?
---@param noteChartSetId number?
---@return number
function NoteChartSetLibrary:getItemIndex(noteChartId, noteChartDataId, noteChartSetId)
	local cdb = self.cacheModel.cacheDatabase
	local ids = cdb.id_to_global_offset
	return (ids[noteChartId] and ids[noteChartId][noteChartDataId] or
		cdb.set_id_to_global_offset[noteChartSetId] or 0) + 1
end

return NoteChartSetLibrary
