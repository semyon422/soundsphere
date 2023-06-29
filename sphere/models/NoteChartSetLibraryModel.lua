local LibraryModel = require("sphere.models.LibraryModel")

local NoteChartSetLibraryModel = LibraryModel:extend()

NoteChartSetLibraryModel.collapse = false

local NoteChartSetItem = {}

NoteChartSetItem.__index = function(self, k)
	local model = self.noteChartSetLibraryModel
	local entry = model.cacheModel.cacheDatabase.noteChartSetItems[self.itemIndex - 1]
	if k == "key" or k == "noteChartDataId" or k == "noteChartId" or k == "setId" or k == "lamp" then
		return entry[k]
	end
	local noteChart = model.cacheModel.cacheDatabase:getCachedEntry("noteCharts", entry.noteChartId)
	local noteChartData = model.cacheModel.cacheDatabase:getCachedEntry("noteChartDatas", entry.noteChartDataId)
	return noteChartData and noteChartData[k] or noteChart and noteChart[k]
end

NoteChartSetLibraryModel.loadObject = function(self, itemIndex)
	return setmetatable({
		noteChartSetLibraryModel = self,
		itemIndex = itemIndex,
	}, NoteChartSetItem)
end

NoteChartSetLibraryModel.updateItems = function(self)
	local params = self.cacheModel.cacheDatabase.queryParams

	local isCollapseAllowed
	params.orderBy, isCollapseAllowed = self.sortModel:getOrderBy()
	if self.collapse and isCollapseAllowed then
		params.groupBy = "noteCharts.setId"
	else
		params.groupBy = nil
	end

	local where, lamp = self.searchModel:getConditions()
	if where ~= "" then
		params.where = where
	else
		params.where = nil
	end
	if lamp ~= "" then
		params.lamp = lamp
	else
		params.lamp = nil
	end

	self.cacheModel.cacheDatabase:asyncQueryAll()
	self.itemsCount = self.cacheModel.cacheDatabase.noteChartSetItemsCount
end

NoteChartSetLibraryModel.findNotechart = function(self, hash, index)
	local params = self.cacheModel.cacheDatabase.queryParams

	params.groupBy = nil
	params.lamp = nil
	params.where = ("noteChartDatas.hash = %q AND noteChartDatas.`index` = %d"):format(hash, index)

	self.cacheModel.cacheDatabase:asyncQueryAll()
	self.itemsCount = self.cacheModel.cacheDatabase.noteChartSetItemsCount
end

NoteChartSetLibraryModel.getItemIndex = function(self, noteChartDataId, noteChartId, noteChartSetId)
	self.entry = self.entry or self.cacheModel.cacheDatabase.EntryStruct()

	local entry = self.entry
	entry.noteChartDataId = noteChartDataId
	entry.noteChartId = noteChartId
	entry.setId = noteChartSetId
	local key = entry.key

	return (self.cacheModel.cacheDatabase.entryKeyToGlobalOffset[key] or self.cacheModel.cacheDatabase.noteChartSetIdToOffset[noteChartSetId] or 0) + 1
end

return NoteChartSetLibraryModel
