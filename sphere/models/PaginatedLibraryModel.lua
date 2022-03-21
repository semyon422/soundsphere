local Class = require("aqua.util.Class")
local aquatimer = require("aqua.timer")

local PaginatedLibraryModel = Class:new()

PaginatedLibraryModel.construct = function(self)
	self.items = {}
	self.pages = {}
	self.requestComplete = false
	self.requestPageNum = 0
	self.requestDelay = 1
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

	local pages = self.pages
	return pages[pageNum] and pages[pageNum][pageItemIndex]
end

PaginatedLibraryModel.unloadPages = function(self, currentPageNum)
	local pages = self.pages
	for pageNum in pairs(pages) do
		if math.abs(pageNum - currentPageNum) > 1 then
			pages[pageNum] = nil
		end
	end
end

PaginatedLibraryModel.update = function(self)
	local currentPageNum = self:getPageNum(self.currentItemIndex)

	self:unloadPages(currentPageNum)
	if currentPageNum == self.requestPageNum and self.requestComplete then
		return
	end
	self.requestComplete = true
	self.requestPageNum = currentPageNum

	print("loadPagesDebounce")
	aquatimer.debounce(self, "loadPagesDebounce", 1, self.loadPages, self)
end

PaginatedLibraryModel.loadPages = function(self)
	local currentPageNum = self:getPageNum(self.currentItemIndex)
	local perPage = self.perPage
	local pages = self.pages
	print("loadPages")
	for pageNum = currentPageNum - 1, currentPageNum + 1 do
		if not pages[pageNum] then
			pages[pageNum] = self:getPage(pageNum, perPage)
			print("PAGE", pageNum, #pages[pageNum])
		end
	end
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
