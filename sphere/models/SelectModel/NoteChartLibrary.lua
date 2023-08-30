local class = require("class")
local ExpireTable = require("ExpireTable")
local table_util = require("table_util")

---@class sphere.NoteChartLibrary
---@operator call: sphere.NoteChartLibrary
local NoteChartLibrary = class()

NoteChartLibrary.setId = 1
NoteChartLibrary.itemsCount = 0

function NoteChartLibrary:new()
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
function NoteChartLibrary:loadObject(itemIndex)
	local chartRepo = self.cacheModel.chartRepo
	local slice = self.cacheModel.cacheDatabase.noteChartSlices[self.setId]
	local entry = self.cacheModel.cacheDatabase.noteChartItems[slice.offset + itemIndex - 1]
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

function NoteChartLibrary:clear()
	self.itemsCount = 0
	self.cache:new()
end

---@param setId number
function NoteChartLibrary:setNoteChartSetId(setId)
	self.setId = setId
	local slice = self.cacheModel.cacheDatabase.noteChartSlices[setId]
	if not slice then
		self.itemsCount = 0
		return
	end
	self.itemsCount = slice.size
	self.cache:new()
end

---@param noteChartId number?
---@return number
function NoteChartLibrary:getItemIndex(noteChartId)
	return (self.cacheModel.cacheDatabase.id_to_local_offset[noteChartId] or 0) + 1
end

return NoteChartLibrary
