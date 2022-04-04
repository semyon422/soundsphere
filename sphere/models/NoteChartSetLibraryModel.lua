local Class = require("aqua.util.Class")

local NoteChartSetLibraryModel = Class:new()

NoteChartSetLibraryModel.searchMode = "hide"
NoteChartSetLibraryModel.collapse = false

NoteChartSetLibraryModel.construct = function(self)
	self.items = {}
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
		local noteChartEntries = self.cacheModel.cacheManager:getNoteChartsAtHash(noteChartDataEntry.hash)
		for _, noteChartEntry in ipairs(noteChartEntries) do
			local setId = noteChartEntry and noteChartEntry.setId
			local noteChartSetEntry = self.cacheModel.cacheManager:getNoteChartSetEntryById(setId)
			local check = self:checkNoteChartDataEntry(noteChartDataEntry, noteChartEntry, noteChartSetEntry)
			if check or self.searchMode == "show" then
				if setId and (not self.collapse or setId ~= prevSetId) then
					items[#items + 1] = {
						noteChartSetEntry = self.cacheModel.cacheManager:getNoteChartSetEntryById(setId),
						noteChartEntry = noteChartEntry,
						noteChartDataEntry = noteChartDataEntry,
						tagged = self.searchMode == "show" and check
					}
				end
				prevSetId = setId
			end
		end
	end
end

NoteChartSetLibraryModel.checkNoteChartDataEntry = function(self, noteChartDataEntry, noteChartEntry, noteChartSetEntry)
	if not noteChartEntry or not noteChartSetEntry then
		return
	end
	return self.searchModel:check(noteChartDataEntry, noteChartEntry, noteChartSetEntry)
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
