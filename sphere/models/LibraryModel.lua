local TimedCache = require("TimedCache")
local Class = require("Class")

local LibraryModel = Class:new()

LibraryModel.construct = function(self)
	self.itemsCount = 0
	self.itemsCache = TimedCache:new()
	self.itemsCache.loadObject = function(_, key)
		return self:loadObject(key)
	end

	self.items = newproxy(true)

	local mt = getmetatable(self.items)
	mt.__index = function(_, i)
		if i < 1 or i > self.itemsCount then
			return
		end
		return self.itemsCache:getObject(i)
	end
	mt.__len = function()
		return self.itemsCount
	end
end

LibraryModel.loadObject = function(self, key) end

LibraryModel.update = function(self)
	self.itemsCache:update()
end

return LibraryModel
