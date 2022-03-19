local Class = require("aqua.util.Class")

local PaginatedLibraryModel = Class:new()

PaginatedLibraryModel.construct = function(self)
	self.items = {}
	self.pages = {}
	self.perPage = 10
	self.itemsCount = 1
	self.currentItemIndex = 1
end

PaginatedLibraryModel.getPageNum = function(self, itemIndex)
	local perPage = self.perPage
	return
		math.floor((itemIndex - 1) / perPage) + 1,
		(itemIndex - 1) % perPage + 1
end

PaginatedLibraryModel.getPageItem = function(self, itemIndex)
	local pageNum, pageItemIndex = self:getPageNum(itemIndex)
	local currentPageNum = self:getPageNum(self.currentItemIndex)
	if math.abs(pageNum - currentPageNum) > 1 then
		return
	end

	self:loadPage(pageNum)
	self:unloadPages(self.currentItemIndex)
	return self.pages[pageNum][pageItemIndex]
end

PaginatedLibraryModel.unloadPages = function(self, itemIndex)
	local currentPageNum = self:getPageNum(itemIndex)
	local pages = self.pages
	for pageNum in pairs(pages) do
		if math.abs(pageNum - currentPageNum) > 1 then
			pages[pageNum] = nil
		end
	end
end

PaginatedLibraryModel.loadPage = function(self, pageNum)
	local pages = self.pages
	if pages[pageNum] then
		return
	end

	if pageNum <= 0 then
		pages[pageNum] = {}
		return
	end

	local perPage = self.perPage
	pages[pageNum] = self:getPage(pageNum, perPage)
end

PaginatedLibraryModel.updateItems = function(self)
	self.items = newproxy(true)
	self.pages = {}

	local mt = getmetatable(self.items)
	mt.__index = function(_, i)
		return self:getPageItem(i)
	end
	mt.__len = function()
		return self.itemsCount
	end
end

return PaginatedLibraryModel
