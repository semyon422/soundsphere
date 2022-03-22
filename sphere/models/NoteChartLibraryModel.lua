local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
local PaginatedLibraryModel = require("sphere.models.PaginatedLibraryModel")
local ObjectQuery = require("sphere.ObjectQuery")
local aquathread = require("aqua.thread")
local aquatimer = require("aqua.timer")

local NoteChartLibraryModel = PaginatedLibraryModel:new()

NoteChartLibraryModel.searchMode = "hide"
NoteChartLibraryModel.setId = 1

NoteChartLibraryModel.load = function(self)
	local objectQuery = ObjectQuery:new()
	self.objectQuery = objectQuery

	CacheDatabase:load()
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

NoteChartLibraryModel._getPage = function(self, pageNum, perPage)
	if pageNum <= 0 then
		return {}
	end
	return self.objectQuery:getPage(pageNum, perPage)
end

local getPage = aquathread.async(function(pageNum, perPage, setId)
	local NoteChartLibraryModel = require("sphere.models.NoteChartLibraryModel")
	local noteChartLibraryModel = NoteChartLibraryModel:new()
	noteChartLibraryModel.setId = setId
	noteChartLibraryModel:load()
	return noteChartLibraryModel:_getPage(pageNum, perPage)
end)

NoteChartLibraryModel.getPage = function(self, pageNum, perPage)
	return getPage(pageNum, perPage, self.setId)
end

NoteChartLibraryModel.updateItems = function(self)
	self.itemsCount = self.objectQuery:getCount()
	self.objectQuery.where = "setId = " .. self.setId
	self.requestComplete = false
	return PaginatedLibraryModel.updateItems(self)
end

NoteChartLibraryModel.getPagePosition = function(self, noteChartDataId, noteChartId)
	for pageNum, page in pairs(self.pages) do
		local offset = (pageNum - 1) * self.perPage
		for i, item in ipairs(page) do
			if item.noteChartDataId == noteChartDataId and item.noteChartId == noteChartId then
				return offset + i
			end
		end
	end
end

NoteChartLibraryModel._getItemIndex = function(self, noteChartDataId, noteChartId)
	print("_GET", self.objectQuery.where)
	return
		self:getPagePosition(noteChartDataId, noteChartId) or
		self.objectQuery:getPosition(noteChartDataId, noteChartId) or
		1
end

NoteChartLibraryModel.getItem = function(self, noteChartDataId, noteChartId)
	local itemIndex = self:getItemIndex(noteChartDataId, noteChartId)
	if itemIndex then
		return self.items[itemIndex]
	end
end

local getItemIndex = aquathread.async(function(noteChartDataId, noteChartId, setId)
	local NoteChartLibraryModel = require("sphere.models.NoteChartLibraryModel")
	local noteChartLibraryModel = NoteChartLibraryModel:new()
	noteChartLibraryModel.setId = setId
	noteChartLibraryModel:load()
	return noteChartLibraryModel:_getItemIndex(noteChartDataId, noteChartId)
end)

NoteChartLibraryModel.getItemIndex = function(self, noteChartDataId, noteChartId)
	return getItemIndex(noteChartDataId, noteChartId, self.setId)
end

return NoteChartLibraryModel
