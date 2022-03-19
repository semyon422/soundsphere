local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
local PaginatedLibraryModel = require("sphere.models.PaginatedLibraryModel")
local ObjectQuery = require("sphere.ObjectQuery")

local NoteChartLibraryModel = PaginatedLibraryModel:new()

NoteChartLibraryModel.searchMode = "hide"
NoteChartLibraryModel.setId = 1

NoteChartLibraryModel.load = function(self)
	local objectQuery = ObjectQuery:new()
	self.objectQuery = objectQuery
	objectQuery.db = CacheDatabase.db

	objectQuery.table = "noteChartDatas"
	objectQuery.fields = {
		"noteChartDatas.*",
		"noteChartDatas.id AS noteChartDataId",
		"noteCharts.id AS noteChartId",
		"noteCharts.path",
		"noteCharts.setId",
		objectQuery:newBooleanCase("tagged", "difficulty > 10"),
	}
	objectQuery:setInnerJoin("noteCharts", "noteChartDatas.hash = noteCharts.hash")
	objectQuery.where = "setId = " .. self.setId
	objectQuery.orderBy = [[
		length(noteChartDatas.inputMode) ASC,
		noteChartDatas.inputMode ASC,
		noteChartDatas.difficulty ASC,
		noteChartDatas.name ASC,
		noteChartDatas.id ASC
	]]
end

NoteChartLibraryModel.setNoteChartSetId = function(self, setId)
	self.setId = setId
end

NoteChartLibraryModel.getPageItem = function(self, itemIndex)
	self.currentItemIndex = self.selectModel.noteChartItemIndex
	return PaginatedLibraryModel.getPageItem(self, itemIndex)
end

NoteChartLibraryModel.getPage = function(self, pageNum, perPage)
	return self.objectQuery:getPage(pageNum, perPage)
end

NoteChartLibraryModel.updateItems = function(self)
	self.itemsCount = self.objectQuery:getCount()
	self.objectQuery.where = "setId = " .. self.setId
	return PaginatedLibraryModel.updateItems(self)
end

NoteChartLibraryModel.getItemIndex = function(self, noteChartDataId, noteChartId)
	return self.objectQuery:getPosition(noteChartDataId, noteChartId) or 1
end

NoteChartLibraryModel.getItem = function(self, noteChartDataId, noteChartId)
	local itemIndex = self:getItemIndex(noteChartDataId, noteChartId)
	if itemIndex then
		return self.items[itemIndex]
	end
end

return NoteChartLibraryModel
