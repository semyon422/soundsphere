local Class = require("aqua.util.Class")

local NoteChartSetLibraryModel = Class:new()

NoteChartSetLibraryModel.searchMode = "hide"
NoteChartSetLibraryModel.collapse = false
NoteChartSetLibraryModel.collection = {path = ""}

NoteChartSetLibraryModel.construct = function(self)
	self.items = {}
end

NoteChartSetLibraryModel.setCollection = function(self, collection)
	self.collection = collection
end

NoteChartSetLibraryModel.updateItems = function(self)
	local items = {}
	self.items = items

	local noteChartDataEntries = self.cacheModel.cacheManager:getNoteChartDatas()
	local sortFunction = self.sortFunction
	if sortFunction then
		table.sort(noteChartDataEntries, sortFunction)
	end

	local prevSetId = 0
	for i = 1, #noteChartDataEntries do
		local noteChartDataEntry = noteChartDataEntries[i]
		local check = self:checkNoteChartDataEntry(noteChartDataEntry)
		if check or self.searchMode == "show" then
			local noteChartEntries = self.cacheModel.cacheManager:getNoteChartsAtHash(noteChartDataEntry.hash)
			local setId = noteChartEntries[1].setId
			if not self.collapse or setId ~= prevSetId then
				items[#items + 1] = {
					noteChartSetEntry = self.cacheModel.cacheManager:getNoteChartSetEntryById(setId),
					noteChartEntry = noteChartEntries[1],
					noteChartDataEntry = noteChartDataEntry,
					tagged = self.searchMode == "show" and check
				}
			end
			prevSetId = setId
		end
	end
end

NoteChartSetLibraryModel.checkNoteChartSetEntry = function(self, entry)
	if not entry.path:find(self.collection.path, 1, true) then
		return false
	end

	local list = self.cacheModel.cacheManager:getNoteChartsAtSet(entry.id)
	if not list or not list[1] then
		return
	end

	for i = 1, #list do
		local entries = self.cacheModel.cacheManager:getAllNoteChartDataEntries(list[i].hash)
		for _, e in pairs(entries) do
			local found = self:checkNoteChartDataEntry(e)
			if found == true then
				return true
			end
		end
	end
end

NoteChartSetLibraryModel.checkNoteChartDataEntry = function(self, entry)
	return self.searchModel:check(entry)
end

NoteChartSetLibraryModel.getItemIndex = function(self, noteChartSetEntryId, noteChartEntryId, noteChartDataEntryId)
	local items = self.items

	if not items then
		return 1
	end

	local collapsedItemIndex
	for i = 1, #items do
		local item = items[i]
		if item.noteChartSetEntry.id == noteChartSetEntryId then
			if item.noteChartEntry.id == noteChartEntryId and item.noteChartDataEntry.id == noteChartDataEntryId then
				return i
			elseif self.collapse then
				collapsedItemIndex = i
			end
		end
	end

	return collapsedItemIndex or 1
end

return NoteChartSetLibraryModel
