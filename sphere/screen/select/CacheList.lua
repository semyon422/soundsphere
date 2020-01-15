local Observable		= require("aqua.util.Observable")
local Cache				= require("sphere.database.Cache")
local CustomList		= require("sphere.ui.CustomList")
local NotificationLine	= require("sphere.ui.NotificationLine")

local CacheList = CustomList:new()

CacheList.needItemsSort = false
CacheList.sender = "CacheList"
CacheList.basePath = ""

CacheList.load = function(self)
	self:selectCache()
	self:reload()
end

CacheList.setBasePath = function(self, path)
	self.basePath = path
	self:selectCache()
end

CacheList.sortItemsFunction = function(a, b)
	return a.name < b.name
end

CacheList.getItem = function(self, entry)
	local item = {}
	
	item.entry = entry
	item.name = self:getItemName(entry)
	
	return item
end

CacheList.getItemIndex = function(self, entry)
	if not entry then
		return 1
	end
	
	local items = self.items
	for i = 1, #items do
		if items[i].entry == entry then
			return i
		end
	end
	
	return 1
end

return CacheList
