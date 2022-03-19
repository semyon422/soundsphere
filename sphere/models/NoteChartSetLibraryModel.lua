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

NoteChartSetLibraryModel.getPagePosition = function(self, noteChartDataId, noteChartId)
	for pageNum, page in pairs(self.pages) do
		local offset = (pageNum - 1) * self.perPage
		for i, item in ipairs(page) do
			if item.noteChartDataId == noteChartDataId and item.noteChartId == noteChartId then
				return offset + i
			end
		end
	end
end

NoteChartSetLibraryModel.getPageSetPosition = function(self, noteChartSetId)
	for pageNum, page in pairs(self.pages) do
		local offset = (pageNum - 1) * self.perPage
		for i, item in ipairs(page) do
			if item.setId == noteChartSetId then
				return offset + i
			end
		end
	end
end

NoteChartSetLibraryModel.getItemIndex = function(self, noteChartDataId, noteChartId, noteChartSetId)
	local objectQuery = self.objectQuery
	if not objectQuery.groupBy then
		return
			self:getPagePosition(noteChartDataId, noteChartId) or
			objectQuery:getPosition(noteChartDataId, noteChartId) or
			1
	end
	return
		self:getPageSetPosition(noteChartSetId) or
		objectQuery:getPosition(noteChartSetId) or
		1
end

return NoteChartSetLibraryModel
