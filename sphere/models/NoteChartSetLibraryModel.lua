local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
local ObjectQuery = require("sphere.ObjectQuery")
local PaginatedLibraryModel = require("sphere.models.PaginatedLibraryModel")

local NoteChartSetLibraryModel = PaginatedLibraryModel:new()

NoteChartSetLibraryModel.searchMode = "hide"
NoteChartSetLibraryModel.collapse = false

NoteChartSetLibraryModel.load = function(self)
	local objectQuery = ObjectQuery:new()
	self.objectQuery = objectQuery
	objectQuery.db = CacheDatabase.db

	objectQuery.table = "noteChartDatas"
	objectQuery.fields = {
		"noteChartDatas.title",
		"noteChartDatas.artist",
		"noteChartDatas.id AS noteChartDataId",
		"noteCharts.id AS noteChartId",
		"noteCharts.path",
		"noteCharts.setId",
		objectQuery:newBooleanCase("tagged", "difficulty > 10"),
	}
	objectQuery:setInnerJoin("noteCharts", "noteChartDatas.hash = noteCharts.hash")
	-- objectQuery.where = "noteChartDatas.inputMode = '4key'"
	objectQuery.orderBy = "noteChartDatas.id ASC"
end

NoteChartSetLibraryModel.getPageItem = function(self, itemIndex)
	self.currentItemIndex = self.selectModel.noteChartSetItemIndex
	return PaginatedLibraryModel.getPageItem(self, itemIndex)
end

NoteChartSetLibraryModel.getPage = function(self, pageNum, perPage)
	return self.objectQuery:getPage(pageNum, perPage)
end

NoteChartSetLibraryModel.updateItems = function(self)
	local objectQuery = self.objectQuery
	objectQuery.groupBy = nil
	if self.collapse then
		objectQuery.groupBy = "noteCharts.setId"
	end

	self.itemsCount = self.objectQuery:getCount()
	return PaginatedLibraryModel.updateItems(self)
end

NoteChartSetLibraryModel.getItemIndex = function(self, noteChartDataId, noteChartId, noteChartSetId)
	local objectQuery = self.objectQuery
	if not objectQuery.groupBy then
		return objectQuery:getPosition(noteChartDataId, noteChartId) or 1
	end
	return objectQuery:getPosition(noteChartSetId) or 1
end

return NoteChartSetLibraryModel
