local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
local LibraryModel = require("sphere.models.LibraryModel")

local NoteChartLibraryModel = LibraryModel:new()

NoteChartLibraryModel.setId = 1

local NoteChartItem = {}

NoteChartItem.getBackgroundPath = function(self)
	local path = self.path
	if not path or not self.stagePath then
		return
	end

	if path:find("%.ojn$") or path:find("%.mid$") then
		return path
	end

	local directoryPath = path:match("^(.+)/(.-)$") or ""
	local stagePath = self.stagePath

	if stagePath and stagePath ~= "" then
		return directoryPath .. "/" .. stagePath
	end

	return directoryPath
end

NoteChartItem.getAudioPathPreview = function(self)
	if not self.path or not self.audioPath then
		return
	end

	local directoryPath = self.path:match("^(.+)/(.-)$") or ""
	local audioPath = self.audioPath

	if audioPath and audioPath ~= "" then
		return directoryPath .. "/" .. audioPath, math.max(0, self.previewTime or 0)
	end

	return directoryPath .. "/preview.ogg", 0
end

NoteChartItem.__index = function(self, k)
	local raw = rawget(NoteChartItem, k)
	if raw then
		return raw
	end
	local model = self.noteChartLibraryModel
	if not model.slice then
		return
	end
	local entry = CacheDatabase.noteChartItems[model.slice.offset + self.itemIndex - 1]
	if k == "key" or k == "noteChartDataId" or k == "noteChartId" or k == "setId" or k == "lamp" then
		return entry[k]
	end
	local noteChart = CacheDatabase:getCachedEntry("noteCharts", entry.noteChartId)
	local noteChartData = CacheDatabase:getCachedEntry("noteChartDatas", entry.noteChartDataId)
	return noteChartData and noteChartData[k] or noteChart and noteChart[k]
end

NoteChartLibraryModel.load = function(self)
	self.itemsCache.loadObject = function(_, itemIndex)
		return setmetatable({
			noteChartLibraryModel = self,
			itemIndex = itemIndex,
		}, NoteChartItem)
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
