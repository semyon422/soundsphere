local Class = require("aqua.util.Class")
local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
local ObjectQuery = require("sphere.ObjectQuery")

local NoteChartSetLibraryModel = Class:new()

NoteChartSetLibraryModel.searchMode = "hide"
NoteChartSetLibraryModel.collapse = false

NoteChartSetLibraryModel.construct = function(self)
	self.items = {}
	self.pages = {}
	self.perPage = 10
end

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
	-- objectQuery.groupBy = "noteCharts.setId"
	objectQuery.orderBy = "noteChartDatas.id ASC"
end

NoteChartSetLibraryModel.newItems = function(self)
	return setmetatable({}, {__index = function(_, i)
		return self:getPageItem(i)
	end})
end

NoteChartSetLibraryModel.getPageNum = function(self, itemIndex)
	local perPage = self.perPage
	return
		math.floor((itemIndex - 1) / perPage) + 1,
		(itemIndex - 1) % perPage + 1
end

NoteChartSetLibraryModel.getPageItem = function(self, itemIndex)
	local pageNum, pageItemIndex = self:getPageNum(itemIndex)
	local currentPageNum = self:getPageNum(self.selectModel.noteChartSetItemIndex)
	if math.abs(pageNum - currentPageNum) > 1 then
		return
	end

	self:loadPage(pageNum)
	self:unloadPages()
	return self.pages[pageNum][pageItemIndex]
end

NoteChartSetLibraryModel.unloadPages = function(self)
	local currentPageNum = self:getPageNum(self.selectModel.noteChartSetItemIndex)
	local pages = self.pages
	for pageNum in pairs(pages) do
		if math.abs(pageNum - currentPageNum) > 1 then
			pages[pageNum] = nil
		end
	end
end

NoteChartSetLibraryModel.loadPage = function(self, pageNum)
	local pages = self.pages
	if pages[pageNum] then
		return
	end

	if pageNum <= 0 then
		pages[pageNum] = {}
		return
	end

	local perPage = self.perPage
	pages[pageNum] = self.objectQuery:getPage(pageNum, perPage)
end

NoteChartSetLibraryModel.updateItems = function(self)
	local itemsCount = self.objectQuery:getCount()

	self.items = newproxy(true)

	local mt = getmetatable(self.items)
	mt.__index = function(_, i)
		return self:getPageItem(i)
	end
	mt.__len = function()
		return itemsCount
	end
end

NoteChartSetLibraryModel.getItemIndex = function(self, noteChartDataEntryId, noteChartEntryId)
	return self.objectQuery:getPosition(noteChartDataEntryId, noteChartEntryId) or 1
end

return NoteChartSetLibraryModel
