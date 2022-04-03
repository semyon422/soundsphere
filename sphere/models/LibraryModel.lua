local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
local TimedCache = require("aqua.util.TimedCache")
local Class = require("aqua.util.Class")

local LibraryModel = Class:new()

LibraryModel.construct = function(self)
	self.items = {}
	self.itemsCount = 1
	self.itemsCache = TimedCache:new()
	self.entry = CacheDatabase.EntryStruct()
	self.items = newproxy(true)

	local mt = getmetatable(self.items)
	mt.__index = function(_, i)
		if i < 1 or i > self.itemsCount then
			return
		end
		return self:getItemByIndex(i)
	end
	mt.__len = function()
		return self.itemsCount
	end
end

LibraryModel.update = function(self)
	self.itemsCache:update()
end

LibraryModel.getItemByIndex = function(self, itemIndex)
	return self.itemsCache:getObject(itemIndex)
end

return LibraryModel
