local Class = require("aqua.util.Class")
local aquatimer = require("aqua.timer")

local LibraryModel = Class:new()

LibraryModel.construct = function(self)
	self.items = {}
	self.pages = {}
	self.requestComplete = false
	self.requestPageNum = 0
	self.requestDelay = 1
	self.perPage = 10
	self.itemsCount = 1
	self.currentItemIndex = 1
	self.scrollDebounceDelay = 0.001
end

-- LibraryModel.getPageNum = function(self, itemIndex)
-- 	local perPage = self.perPage
-- 	return
-- 		math.floor((itemIndex - 1) / perPage) + 1,
-- 		(itemIndex - 1) % perPage + 1
-- end

-- LibraryModel.getPageItem = function(self, itemIndex)
-- 	local pageNum, pageItemIndex = self:getPageNum(itemIndex)
-- 	local currentPageNum = self:getPageNum(self.currentItemIndex)
-- 	if math.abs(pageNum - currentPageNum) > 1 then
-- 		return
-- 	end

-- 	local pages = self.pages
-- 	return pages[pageNum] and pages[pageNum][pageItemIndex]
-- end

-- LibraryModel.unloadPages = function(self, currentPageNum)
-- 	local pages = self.pages
-- 	for pageNum in pairs(pages) do
-- 		if math.abs(pageNum - currentPageNum) > 1 then
-- 			pages[pageNum] = nil
-- 		end
-- 	end
-- end

LibraryModel.update = function(self)
	-- local currentPageNum = self:getPageNum(self.currentItemIndex)

	-- self:unloadPages(currentPageNum)
	-- if currentPageNum == self.requestPageNum and self.requestComplete then
	-- 	return
	-- end
	-- self.requestComplete = true
	-- self.requestPageNum = currentPageNum

	-- print("loadPagesDebounce")
	-- aquatimer.debounce(self, "loadPagesDebounce", self.scrollDebounceDelay, self.loadPages, self)
end

LibraryModel.getItemByIndex = function(self, itemIndex)
	return {}
end

-- LibraryModel.loadPages = function(self)
-- 	local currentPageNum = self:getPageNum(self.currentItemIndex)
-- 	local perPage = self.perPage
-- 	local pages = self.pages
-- 	print("loadPages")
-- 	for pageNum = currentPageNum - 1, currentPageNum + 1 do
-- 		if not pages[pageNum] then
-- 			pages[pageNum] = self:getPage(pageNum, perPage)
-- 			print("PAGE", pageNum, #pages[pageNum])
-- 		end
-- 	end
-- end

LibraryModel.updateItems = function(self)
	self.items = newproxy(true)
	self.pages = {}

	local mt = getmetatable(self.items)
	mt.__index = function(_, i)
		return self:getItemByIndex(i)
	end
	mt.__len = function()
		return self.itemsCount
	end
end

return LibraryModel
