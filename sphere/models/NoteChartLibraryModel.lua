local Class = require("aqua.util.Class")
local SearchManager			= require("sphere.database.SearchManager")

local NoteChartLibraryModel = Class:new()

NoteChartLibraryModel.construct = function(self)
	self:setNoteChartSetId(1)
	self:setSearchString("")
end

NoteChartLibraryModel.setNoteChartSetId = function(self, setId)
	self.setId = setId
	self.items = nil
end

NoteChartLibraryModel.setSearchString = function(self, searchString)
	self.searchString = searchString
	self.items = nil
end

NoteChartLibraryModel.getItems = function(self)
	if not self.items then
		self:updateItems()
	end
	return self.items
end

NoteChartLibraryModel.updateItems = function(self)
	local items = {}
	self.items = items

	local noteChartEntries = self.cacheModel.cacheManager:getNoteChartsAtSet(self.setId)
	if not noteChartEntries or not noteChartEntries[1] then
		return items
	end

	local map = {}
	local noteChartDataEntries = {}
	for i = 1, #noteChartEntries do
		local allEntries = self.cacheModel.cacheManager:getAllNoteChartDataEntries(noteChartEntries[i].hash)
		if #allEntries == 0 then
			allEntries = {self.cacheModel.cacheManager:getEmptyNoteChartDataEntry(noteChartEntries[i].path)}
		end
		for _, entry in pairs(allEntries) do
			noteChartDataEntries[#noteChartDataEntries + 1] = entry
			map[entry] = noteChartEntries[i]
		end
	end

	local foundList = SearchManager:search(noteChartDataEntries, self.searchString)
	for i = 1, #foundList do
		local noteChartDataEntry = foundList[i]
		items[#items + 1] = {
			noteChartDataEntry = noteChartDataEntry,
			noteChartEntry = map[noteChartDataEntry]
		}
	end

	table.sort(items, self.sortItemsFunction)
end

NoteChartLibraryModel.sortItemsFunction = function(a, b)
	a, b = a.noteChartDataEntry, b.noteChartDataEntry
	if
		#a.inputMode < #b.inputMode or
		#a.inputMode == #b.inputMode and a.inputMode < b.inputMode or
		a.inputMode == b.inputMode and a.noteCount / a.length < b.noteCount / b.length
	then
		return true
	end
end

-- NoteChartLibraryModel.getBackgroundPath = function(self, itemIndex)
-- 	local item = self.items[itemIndex]
-- 	local noteChartDataEntry = item.noteChartDataEntry
-- 	local noteChartEntry = item.noteChartEntry

-- 	local directoryPath = self.cacheModel.cacheManager:getNoteChartSetEntryById(noteChartEntry.setId).path
-- 	local stagePath = noteChartDataEntry.stagePath

-- 	if stagePath and stagePath ~= "" then
-- 		return directoryPath .. "/" .. stagePath
-- 	end

-- 	return directoryPath
-- end

-- NoteChartList.getAudioPath = function(self, itemIndex)
-- 	local item = self.items[itemIndex]
-- 	local noteChartDataEntry = item.noteChartDataEntry
-- 	local noteChartEntry = item.noteChartEntry

-- 	local directoryPath = self.cacheModel.cacheManager:getNoteChartSetEntryById(noteChartEntry.setId).path
-- 	local audioPath = noteChartDataEntry.audioPath

-- 	if audioPath and audioPath ~= "" then
-- 		return directoryPath .. "/" .. audioPath, noteChartDataEntry.previewTime
-- 	end

-- 	return directoryPath .. "/preview.ogg", 0
-- end

-- NoteChartList.getItemIndex = function(self, entry)
-- 	if not entry then
-- 		return 1
-- 	end

-- 	local items = self.items
-- 	for i = 1, #items do
-- 		if items[i].noteChartEntry == entry then
-- 			return i
-- 		end
-- 	end

-- 	return 1
-- end

return NoteChartLibraryModel
