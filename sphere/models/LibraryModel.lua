local TimedCache = require("TimedCache")
local class = require("class")

local LibraryModel = class()

function LibraryModel:new()
	self.itemsCount = 0
	self.itemsCache = TimedCache()
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

function LibraryModel:loadObject(key) end

function LibraryModel:update()
	self.itemsCache:update()
end

return LibraryModel
