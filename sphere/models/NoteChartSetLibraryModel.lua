local Class = require("aqua.util.Class")
local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")

local NoteChartSetLibraryModel = Class:new()

NoteChartSetLibraryModel.searchMode = "hide"
NoteChartSetLibraryModel.collapse = false

NoteChartSetLibraryModel.construct = function(self)
	self.items = {}
end

NoteChartSetLibraryModel.updateItems = function(self)
	CacheDatabase:load()
	self.items = CacheDatabase.db:query([[
		SELECT noteChartDatas.*, noteChartDatas.id AS noteChartDataId, noteCharts.id AS noteChartId, noteCharts.path, noteCharts.setId,
			CASE WHEN difficulty > 10 THEN TRUE
			ELSE FALSE
			END __boolean_tagged
		FROM noteChartDatas
		INNER JOIN noteCharts ON noteChartDatas.hash = noteCharts.hash
		ORDER BY id
	]]) or {}
	CacheDatabase:unload()
end

NoteChartSetLibraryModel.getItemIndex = function(self, noteChartSetEntryId, noteChartEntryId, noteChartDataEntryId)
	CacheDatabase:load()
	local result = CacheDatabase.db:query([[
		SELECT * FROM
		(
			SELECT ROW_NUMBER() OVER(ORDER BY noteChartDatas.id) AS pos, noteCharts.id as ncId, noteChartDatas.id as ncdId, noteCharts.setId
			FROM noteChartDatas
			INNER JOIN noteCharts ON noteChartDatas.hash = noteCharts.hash
		) A
		WHERE setId = ? AND ncId = ? and ncdId = ?
	]], noteChartSetEntryId, noteChartEntryId, noteChartDataEntryId)
	CacheDatabase:unload()
	return result and result[1] and tonumber(result[1].pos) or 1
end

return NoteChartSetLibraryModel
