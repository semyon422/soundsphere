local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
local LibraryModel = require("sphere.models.LibraryModel")

local NoteChartLibraryModel = LibraryModel:new()

NoteChartLibraryModel.setId = 1

NoteChartLibraryModel.load = function(self)
	self.itemsCache.loadObject = function(_, itemIndex)
		return setmetatable({}, {__index = function(t, k)
			if not self.slice then
				return
			end
			local entry = CacheDatabase.noteChartItems[self.slice.offset + itemIndex - 1]
			if k == "key" or k == "noteChartDataId" or k == "noteChartId" or k == "setId" or k == "lamp" then
				return entry[k]
			end
			local noteChart = CacheDatabase:getCachedEntry("noteCharts", entry.noteChartId)
			local noteChartData = CacheDatabase:getCachedEntry("noteChartDatas", entry.noteChartDataId)
			return noteChartData and noteChartData[k] or noteChart and noteChart[k]
		end})
	end
end

NoteChartLibraryModel.clear = function(self)
	self.slice = nil
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

NoteChartLibraryModel.getItemIndex = function(self, noteChartDataId, noteChartId, noteChartSetId)
	if not noteChartDataId or not noteChartId or not noteChartSetId then
		return 1
	end

	local entry = self.entry
	entry.noteChartDataId = noteChartDataId
	entry.noteChartId = noteChartId
	entry.setId = noteChartSetId
	local key = entry.key

	return (CacheDatabase.entryKeyToLocalOffset[key] or 0) + 1
end

return NoteChartLibraryModel
