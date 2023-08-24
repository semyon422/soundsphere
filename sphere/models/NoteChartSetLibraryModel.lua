local class = require("class")
local ExpireTable = require("ExpireTable")
local Orm = require("sphere.Orm")
local table_util = require("table_util")

---@class sphere.NoteChartSetLibraryModel
---@operator call: sphere.NoteChartSetLibraryModel
local NoteChartSetLibraryModel = class()

NoteChartSetLibraryModel.itemsCount = 0

function NoteChartSetLibraryModel:new()
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

NoteChartSetLibraryModel.collapse = false

---@param itemIndex number
---@return table
function NoteChartSetLibraryModel:loadObject(itemIndex)
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

function NoteChartSetLibraryModel:updateItems()
	local params = self.cacheModel.cacheDatabase.queryParams

	local orderBy, isCollapseAllowed = self.sortModel:getOrderBy()
	local fields = {}
	for i, field in ipairs(orderBy) do
		fields[i] = "noteChartDatas." .. field .. " ASC"
	end
	params.orderBy = table.concat(fields, ",")

	if self.collapse and isCollapseAllowed then
		params.groupBy = "noteCharts.setId"
	else
		params.groupBy = nil
	end

	local where, lamp = self.searchModel:getConditions()

	params.where = Orm:build_condition(where)
	params.lamp = lamp and Orm:build_condition(lamp)

	self.cacheModel.cacheDatabase:asyncQueryAll()
	self.itemsCount = self.cacheModel.cacheDatabase.noteChartSetItemsCount
	self.cache:new()
end

---@param hash string
---@param index number
function NoteChartSetLibraryModel:findNotechart(hash, index)
	local params = self.cacheModel.cacheDatabase.queryParams

	params.groupBy = nil
	params.lamp = nil
	params.where = ("noteChartDatas.hash = %q AND noteChartDatas.`index` = %d"):format(hash, index)

	self.cacheModel.cacheDatabase:asyncQueryAll()
	self.itemsCount = self.cacheModel.cacheDatabase.noteChartSetItemsCount
	self.cache:new()
end

---@param noteChartId number?
---@param noteChartSetId number?
---@return number
function NoteChartSetLibraryModel:getItemIndex(noteChartId, noteChartSetId)
	local cdb = self.cacheModel.cacheDatabase
	return (cdb.id_to_global_offset[noteChartId] or cdb.set_id_to_global_offset[noteChartSetId] or 0) + 1
end

return NoteChartSetLibraryModel
