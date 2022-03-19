local Class = require("aqua.util.Class")
local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")

local NoteChartSetLibraryModel = Class:new()

NoteChartSetLibraryModel.searchMode = "hide"
NoteChartSetLibraryModel.collapse = false

NoteChartSetLibraryModel.construct = function(self)
	self.items = {}
	self.pages = {}
	self.perPage = 10
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
	pages[pageNum] = CacheDatabase.db:query([[
		SELECT noteChartDatas.*, noteChartDatas.id AS noteChartDataId, noteCharts.id AS noteChartId, noteCharts.path, noteCharts.setId,
			CASE WHEN difficulty > 10 THEN TRUE
			ELSE FALSE
			END __boolean_tagged
		FROM noteChartDatas
		INNER JOIN noteCharts ON noteChartDatas.hash = noteCharts.hash
		ORDER BY id
		LIMIT ?
		OFFSET ?
	]], perPage, (pageNum - 1) * perPage) or {}
end

NoteChartSetLibraryModel.updateItems = function(self)
	local itemsCount = CacheDatabase.db:query([[
		SELECT COUNT(1) as c
		FROM noteChartDatas
		INNER JOIN noteCharts ON noteChartDatas.hash = noteCharts.hash
	]])[1].c

	self.items = newproxy(true)

	local mt = getmetatable(self.items)
	mt.__index = function(_, i)
		return self:getPageItem(i)
	end
	mt.__len = function()
		return itemsCount
	end
end

NoteChartSetLibraryModel.getItemIndex = function(self, noteChartSetEntryId, noteChartEntryId, noteChartDataEntryId)
	local result = CacheDatabase.db:query([[
		SELECT * FROM
		(
			SELECT ROW_NUMBER() OVER(ORDER BY noteChartDatas.id) AS pos, noteCharts.id as ncId, noteChartDatas.id as ncdId, noteCharts.setId
			FROM noteChartDatas
			INNER JOIN noteCharts ON noteChartDatas.hash = noteCharts.hash
		) A
		WHERE setId = ? AND ncId = ? and ncdId = ?
	]], noteChartSetEntryId, noteChartEntryId, noteChartDataEntryId)
	return result and result[1] and tonumber(result[1].pos) or 1
end

return NoteChartSetLibraryModel
