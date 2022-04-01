local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
local ObjectQuery = require("sphere.ObjectQuery")
local LibraryModel = require("sphere.models.LibraryModel")
local aquathread = require("aqua.thread")
local aquatimer = require("aqua.timer")

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
	return CacheDatabase.noteChartSetItems[itemIndex - 1]
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
