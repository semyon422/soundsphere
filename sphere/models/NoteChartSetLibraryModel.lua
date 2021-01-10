local Class = require("aqua.util.Class")

local NoteChartSetLibraryModel = Class:new()

NoteChartSetLibraryModel.construct = function(self)

end

NoteChartSetLibraryModel.getItems = function(self, searchString)
	if not self.items or self.searchString ~= searchString then
		self:updateItems(searchString)
		self.searchString = searchString
	end
	return self.items
end

NoteChartSetLibraryModel.updateItems = function(self, searchString)
	local items = {}
	self.items = items

	local noteChartSetEntries = self.cacheModel.cacheManager:getNoteChartSets()
	for i = 1, #noteChartSetEntries do
		local noteChartSetEntry = noteChartSetEntries[i]
		if self:checkNoteChartSetEntry(noteChartSetEntry) then
			items[#items + 1] = {
				noteChartSetEntry = noteChartSetEntry,
				name = noteChartSetEntry.path:match(".+/(.-)$")
			}
		end
	end
end


NoteChartSetLibraryModel.checkNoteChartSetEntry = function(self, entry)
	return true
	-- local base = entry.path:find(self.basePath, 1, true)
	-- if not base then return false end
	-- if not self.needSearch then return true end

	-- local list = self.cacheModel.cacheManager:getNoteChartsAtSet(entry.id)
	-- if not list or not list[1] then
	-- 	return
	-- end

	-- for i = 1, #list do
	-- 	local entries = self.cacheModel.cacheManager:getAllNoteChartDataEntries(list[i].hash)
	-- 	for _, entry in pairs(entries) do
	-- 		local found = SearchManager:check(entry, self.searchString)
	-- 		if found == true then
	-- 			return true
	-- 		end
	-- 	end
	-- end
end

-- NoteChartSetList.sortItemsFunction = function(a, b)
-- 	return a.noteChartSetEntry.path < b.noteChartSetEntry.path
-- end

-- NoteChartSetList.getItemName = function(self, entry)
-- 	local list = self.cacheModel.cacheManager:getNoteChartsAtSet(entry.id)
-- 	if list and list[1] then
-- 		local noteChartDataEntry = self.cacheModel.cacheManager:getNoteChartDataEntry(list[1].hash, 1)
-- 		if noteChartDataEntry then
-- 			return noteChartDataEntry.title
-- 		end
-- 	end
-- 	return entry.path:match(".+/(.-)$")
-- end

-- NoteChartSetList.selectCache = function(self)
-- end

-- NoteChartSetList.getItemIndex = function(self, entry)
-- 	if not entry then
-- 		return 1
-- 	end

-- 	local items = self.items
-- 	for i = 1, #items do
-- 		if items[i].noteChartSetEntry == entry then
-- 			return i
-- 		end
-- 	end

-- 	return 1
-- end

return NoteChartSetLibraryModel
