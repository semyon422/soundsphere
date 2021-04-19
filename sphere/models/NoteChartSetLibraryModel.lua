local Class = require("aqua.util.Class")
local SearchManager			= require("sphere.database.SearchManager")

local NoteChartSetLibraryModel = Class:new()

NoteChartSetLibraryModel.construct = function(self)
	self.searchString = ""
	self.items = {}
end

NoteChartSetLibraryModel.setSearchString = function(self, searchString)
	if searchString == self.searchString then
		return
	end
	self.searchString = searchString
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
	-- local base = entry.path:find(self.basePath, 1, true)
	-- if not base then return false end
	-- if not self.needSearch then return true end

	local list = self.cacheModel.cacheManager:getNoteChartsAtSet(entry.id)
	if not list or not list[1] then
		return
	end

	for i = 1, #list do
		local entries = self.cacheModel.cacheManager:getAllNoteChartDataEntries(list[i].hash)
		for _, entry in pairs(entries) do
			local found = SearchManager:check(entry, self.searchString)
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
