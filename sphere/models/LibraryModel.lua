local Class = require("aqua.util.Class")

local LibraryModel = Class:new()

LibraryModel.construct = function(self)
	self.items = {}
	self.itemsCount = 1
end

LibraryModel.getItemByIndex = function(self, itemIndex)
	return {}
end

LibraryModel.updateItems = function(self)
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

return LibraryModel
