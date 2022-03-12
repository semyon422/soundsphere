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
	if #a.inputMode ~= #b.inputMode then
		return #a.inputMode < #b.inputMode
	elseif a.inputMode ~= b.inputMode then
		return a.inputMode < b.inputMode
	elseif a.difficulty ~= b.difficulty then
		return a.difficulty < b.difficulty
	elseif a.name ~= b.name then
		return a.name < b.name
	end
	return a.id < b.id
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
	local itemIndex = self:getItemIndex(noteChartEntryId, noteChartDataEntryId)
	if itemIndex then
		return self.items[itemIndex]
	end
end

return NoteChartLibraryModel
