local TimedCache = require("aqua.util.TimedCache")
local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
local LibraryModel = require("sphere.models.LibraryModel")

local NoteChartLibraryModel = LibraryModel:new()

NoteChartLibraryModel.searchMode = "hide"
NoteChartLibraryModel.setId = 1

NoteChartLibraryModel.load = function(self)
	self.entry = CacheDatabase.EntryStruct()
	self.itemsCount = 0
	self.itemsCache = TimedCache:new()
	self.itemsCache.loadObject = function(_, itemIndex)
		return setmetatable({}, {__index = function(t, k)
			local entry = CacheDatabase.noteChartItems[self.slice.offset + itemIndex - 1]
			if k == "key" or k == "noteChartDataId" or k == "noteChartId" or k == "setId" then
				return entry[k]
			end
			local noteChart = CacheDatabase:getCachedEntry("noteCharts", entry.noteChartId)
			local noteChartData = CacheDatabase:getCachedEntry("noteChartDatas", entry.noteChartDataId)
			return noteChartData[k] or noteChart[k]
		end})
	end
end

NoteChartLibraryModel.update = function(self)
	self.itemsCache:update()
end

NoteChartLibraryModel.getItemByIndex = function(self, itemIndex)
	return self.itemsCache:getObject(itemIndex)
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

NoteChartLibraryModel.getItemIndex = function(self, noteChartDataId, noteChartId, noteChartSetId)
	local entry = self.entry
	entry.noteChartDataId = noteChartDataId
	entry.noteChartId = noteChartId
	entry.setId = noteChartSetId
	local key = entry.key

	return (CacheDatabase.entryKeyToLocalOffset[key] or 0) + 1
end

return NoteChartLibraryModel
