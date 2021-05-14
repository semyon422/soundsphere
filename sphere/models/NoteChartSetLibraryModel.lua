local Class = require("aqua.util.Class")

local NoteChartSetLibraryModel = Class:new()

NoteChartSetLibraryModel.construct = function(self)
	self.collection = ""
	self.items = {}
end

NoteChartSetLibraryModel.setCollection = function(self, collection)
	self.collection = collection
end

NoteChartSetLibraryModel.updateItems = function(self)
	local items = {}
	self.items = items

	local noteChartSetEntries = self.cacheModel.cacheManager:getNoteChartSets()
	for i = 1, #noteChartSetEntries do
		local noteChartSetEntry = noteChartSetEntries[i]
		if self:checkNoteChartSetEntry(noteChartSetEntry) then
			local noteChartEntries = self.cacheModel.cacheManager:getNoteChartsAtSet(noteChartSetEntry.id)
			local noteChartDataEntries = self.cacheModel.cacheManager:getAllNoteChartDataEntries(noteChartEntries[1].hash)
			items[#items + 1] = {
				noteChartSetEntry = noteChartSetEntry,
				noteChartEntries = noteChartEntries,
				noteChartDataEntries = noteChartDataEntries
			}
		end
	end
end


NoteChartSetLibraryModel.checkNoteChartSetEntry = function(self, entry)
	if not entry.path:find(self.collection, 1, true) then
		return false
	end

	local list = self.cacheModel.cacheManager:getNoteChartsAtSet(entry.id)
	if not list or not list[1] then
		return
	end

	for i = 1, #list do
		local entries = self.cacheModel.cacheManager:getAllNoteChartDataEntries(list[i].hash)
		for _, entry in pairs(entries) do
			local found = self.searchModel:check(entry)
			if found == true then
				return true
			end
		end
	end
end

NoteChartSetLibraryModel.sortItemsFunction = function(a, b)
	return a.noteChartSetEntry.path < b.noteChartSetEntry.path
end

NoteChartSetLibraryModel.getItemIndex = function(self, noteChartSetEntryId)
	local items = self.items

	if not items then
		return 1
	end

	for i = 1, #items do
		if items[i].noteChartSetEntry.id == noteChartSetEntryId then
			return i
		end
	end

	return 1
end

return NoteChartSetLibraryModel
