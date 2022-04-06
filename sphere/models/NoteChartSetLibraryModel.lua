local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
local LibraryModel = require("sphere.models.LibraryModel")

local NoteChartSetLibraryModel = LibraryModel:new()

NoteChartSetLibraryModel.collapse = false

NoteChartSetLibraryModel.load = function(self)
	self.itemsCache.getObject = function(_, itemIndex)
		return setmetatable({}, {__index = function(t, k)
			local entry = CacheDatabase.noteChartSetItems[itemIndex - 1]
			if k == "key" or k == "noteChartDataId" or k == "noteChartId" or k == "setId" or k == "lamp" then
				return entry[k]
			end
			local noteChart = CacheDatabase:getCachedEntry("noteCharts", entry.noteChartId)
			local noteChartData = CacheDatabase:getCachedEntry("noteChartDatas", entry.noteChartDataId)
			return noteChartData[k] or noteChart[k]
		end})
	end
end

NoteChartSetLibraryModel.updateItems = function(self)
	local params = CacheDatabase.queryParams

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

	CacheDatabase:asyncQueryAll()
	self.itemsCount = CacheDatabase.noteChartSetItemsCount
end

NoteChartSetLibraryModel.getItemIndex = function(self, noteChartDataId, noteChartId, noteChartSetId)
	local entry = self.entry
	entry.noteChartDataId = noteChartDataId
	entry.noteChartId = noteChartId
	entry.setId = noteChartSetId
	local key = entry.key

	return (CacheDatabase.entryKeyToGlobalOffset[key] or CacheDatabase.noteChartSetIdToOffset[noteChartSetId] or 0) + 1
end

return NoteChartSetLibraryModel
