local LibraryModel = require("sphere.models.LibraryModel")
local Orm = require("sphere.Orm")

---@class sphere.NoteChartSetLibraryModel: sphere.LibraryModel
---@operator call: sphere.NoteChartSetLibraryModel
local NoteChartSetLibraryModel = LibraryModel + {}

NoteChartSetLibraryModel.collapse = false

local NoteChartSetItem = {}

---@param k any
---@return any?
function NoteChartSetItem:__index(k)
	local model = self.noteChartSetLibraryModel
	local entry = model.cacheModel.cacheDatabase.noteChartSetItems[self.itemIndex - 1]
	if k == "key" or k == "noteChartDataId" or k == "noteChartId" or k == "setId" or k == "lamp" then
		return entry[k]
	end
	local noteChart = model.cacheModel.cacheDatabase:getCachedEntry("noteCharts", entry.noteChartId)
	local noteChartData = model.cacheModel.cacheDatabase:getCachedEntry("noteChartDatas", entry.noteChartDataId)
	return noteChartData and noteChartData[k] or noteChart and noteChart[k]
end

---@param itemIndex number
---@return table
function NoteChartSetLibraryModel:loadObject(itemIndex)
	return setmetatable({
		noteChartSetLibraryModel = self,
		itemIndex = itemIndex,
	}, NoteChartSetItem)
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
end

---@param noteChartId number?
---@param noteChartSetId number?
---@return number
function NoteChartSetLibraryModel:getItemIndex(noteChartId, noteChartSetId)
	local cdb = self.cacheModel.cacheDatabase
	return (cdb.id_to_global_offset[noteChartId] or cdb.set_id_to_global_offset[noteChartSetId] or 0) + 1
end

return NoteChartSetLibraryModel
