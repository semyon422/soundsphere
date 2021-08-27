local Class = require("aqua.util.Class")

local NoteChartLibraryModel = Class:new()

NoteChartLibraryModel.searchMode = "hide"
NoteChartLibraryModel.setId = 1

NoteChartLibraryModel.construct = function(self)
	self.items = {}
end

NoteChartLibraryModel.setNoteChartSetId = function(self, setId)
	if setId == self.setId then
		return
	end
	self.setId = setId
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

	local foundList, foundMap = self.searchModel:search(noteChartDataEntries)
	for i = 1, #noteChartDataEntries do
		local noteChartDataEntry = noteChartDataEntries[i]
		local check = foundMap[noteChartDataEntry]
		if check or self.searchMode == "show" then
			items[#items + 1] = {
				noteChartDataEntry = noteChartDataEntry,
				noteChartEntry = map[noteChartDataEntry],
				tagged = self.searchMode == "show" and check
			}
		end
	end

	table.sort(items, self.sortItemsFunction)
end

NoteChartLibraryModel.sortItemsFunction = function(a, b)
	a, b = a.noteChartDataEntry, b.noteChartDataEntry
	if
		#a.inputMode < #b.inputMode or
		#a.inputMode == #b.inputMode and a.inputMode < b.inputMode or
		a.inputMode == b.inputMode and a.noteCount < b.noteCount
	then
		return true
	end
end

NoteChartLibraryModel.getItemIndex = function(self, noteChartEntryId, noteChartDataEntryId)
	local items = self.items

	if not items then
		return 1
	end

	for i = 1, #items do
		local item = items[i]
		if item.noteChartEntry.id == noteChartEntryId and item.noteChartDataEntry.id == noteChartDataEntryId then
			return i
		end
	end

	return 1
end

NoteChartLibraryModel.getItem = function(self, noteChartEntryId, noteChartDataEntryId)
	return self.items[self:getItemIndex(noteChartEntryId, noteChartDataEntryId)]
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

return NoteChartLibraryModel
