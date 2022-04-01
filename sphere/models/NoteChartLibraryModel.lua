local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
local LibraryModel = require("sphere.models.LibraryModel")
local ObjectQuery = require("sphere.ObjectQuery")
local aquathread = require("aqua.thread")
local aquatimer = require("aqua.timer")

local NoteChartLibraryModel = LibraryModel:new()

NoteChartLibraryModel.searchMode = "hide"
NoteChartLibraryModel.setId = 1

NoteChartLibraryModel.load = function(self)
	self.entry = CacheDatabase.EntryStruct()
	self.itemsCount = 0
end

NoteChartLibraryModel.setNoteChartSetId = function(self, setId)
	self.setId = setId
	local slice = CacheDatabase.noteChartSlices[setId]
	self.slice = slice
	if not slice then
		self.itemsCount = 0
		return
	end
	self.itemsCount = slice.size
end

NoteChartLibraryModel.getItemByIndex = function(self, itemIndex)
	self.currentItemIndex = self.selectModel.noteChartItemIndex
	if itemIndex < 1 or itemIndex > self.itemsCount then
		return
	end
	return CacheDatabase.noteChartItems[self.slice.offset + itemIndex - 1]
end

NoteChartLibraryModel.getItemIndex = function(self, noteChartDataId, noteChartId, noteChartSetId)
	local entry = self.entry
	entry.noteChartDataId = noteChartDataId
	entry.noteChartId = noteChartId
	entry.setId = noteChartSetId
	local key = entry.key

	return (CacheDatabase.entryKeyToLocalOffset[key] or 0) + 1
end

return NoteChartLibraryModel
