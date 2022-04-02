local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
local LibraryModel = require("sphere.models.LibraryModel")

local NoteChartSetLibraryModel = LibraryModel:new()

NoteChartSetLibraryModel.searchMode = "hide"
NoteChartSetLibraryModel.collapse = false

NoteChartSetLibraryModel.load = function(self)
	self.entry = CacheDatabase.EntryStruct()
	self.itemsCount = CacheDatabase.noteChartSetItemsCount
end

NoteChartSetLibraryModel.getItemByIndex = function(self, itemIndex)
	self.currentItemIndex = self.selectModel.noteChartSetItemIndex
	if itemIndex < 1 or itemIndex > self.itemsCount then
		return
	end
	return setmetatable({}, {__index = function(t, k)
		local entry = CacheDatabase.noteChartSetItems[itemIndex - 1]
		if k == "key" or k == "noteChartDataId" or k == "noteChartId" or k == "setId" then
			return entry[k]
		end
		-- local noteChartSet = CacheDatabase:getCachedEntry("noteChartSets", entry.setId)
		local noteChart = CacheDatabase:getCachedEntry("noteCharts", entry.noteChartId)
		local noteChartData = CacheDatabase:getCachedEntry("noteChartDatas", entry.noteChartDataId)
		return noteChartData[k] or noteChart[k]
	end})
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
