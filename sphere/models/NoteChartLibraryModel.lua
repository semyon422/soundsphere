local Class = require("aqua.util.Class")
local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")

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
	CacheDatabase:load()
	self.items = CacheDatabase.db:query([[
		SELECT noteChartDatas.*, noteChartDatas.id AS noteChartDataId, noteCharts.id AS noteChartId, noteCharts.path, noteCharts.setId,
			CASE WHEN difficulty > 10 THEN TRUE
			ELSE FALSE
			END __boolean_tagged
		FROM noteChartDatas
		INNER JOIN noteCharts ON noteChartDatas.hash = noteCharts.hash
		WHERE setId = ?
		ORDER BY id
	]], self.setId) or {}
	CacheDatabase:unload()
end

-- NoteChartLibraryModel.sortItemsFunction = function(a, b)
-- 	a, b = a.noteChartDataEntry, b.noteChartDataEntry
-- 	if #a.inputMode ~= #b.inputMode then
-- 		return #a.inputMode < #b.inputMode
-- 	elseif a.inputMode ~= b.inputMode then
-- 		return a.inputMode < b.inputMode
-- 	elseif a.difficulty ~= b.difficulty then
-- 		return a.difficulty < b.difficulty
-- 	elseif a.name ~= b.name then
-- 		return a.name < b.name
-- 	end
-- 	return a.id < b.id
-- end

NoteChartLibraryModel.getItemIndex = function(self, noteChartEntryId, noteChartDataEntryId)
	CacheDatabase:load()
	local result = CacheDatabase.db:query([[
		SELECT * FROM
		(
			SELECT ROW_NUMBER() OVER(ORDER BY noteChartDatas.id) AS pos, noteCharts.id as ncId, noteChartDatas.id as ncdId, noteCharts.setId
			FROM noteChartDatas
			INNER JOIN noteCharts ON noteChartDatas.hash = noteCharts.hash
			WHERE setId = ?
		) A
		WHERE setId = ? AND ncId = ? and ncdId = ?
	]], self.setId, self.setId, noteChartEntryId, noteChartDataEntryId)
	CacheDatabase:unload()
	return result and result[1] and tonumber(result[1].pos) or 1
end

NoteChartLibraryModel.getItem = function(self, noteChartEntryId, noteChartDataEntryId)
	local itemIndex = self:getItemIndex(noteChartEntryId, noteChartDataEntryId)
	if itemIndex then
		return self.items[itemIndex]
	end
end

return NoteChartLibraryModel
