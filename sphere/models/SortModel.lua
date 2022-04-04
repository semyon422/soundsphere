local Class = require("aqua.util.Class")
local sort = require("aqua.util.sort")

local SortModel = Class:new()

SortModel.getSortFunction = function(self)
	return self.sortItemsFunctions[self.name]
end

SortModel.sortItemsFunctions = {
	id = function(a, b) return a.id < b.id end,
	title = sort("title", "artist", "creator", "difficulty", "id"),
	artist = sort("artist", "title", "creator", "difficulty", "id"),
	difficulty = sort("difficulty", "id"),
	level = sort("level", "id"),
	length = sort("length", "id"),
	bpm = sort("bpm", "id"),
}

SortModel.name = "title"
SortModel.names = {"id", "title", "artist", "difficulty", "level", "length", "bpm"}

SortModel.toIndexValue = function(self, name)
	for i, currentName in ipairs(self.names) do
		if name == currentName then
			return i
		end
	end
	return 1
end

SortModel.fromIndexValue = function(self, indexValue)
	return self.names[math.min(math.max(indexValue, 1), #self.names)] or ""
end

SortModel.increase = function(self, delta)
	local indexValue = self:toIndexValue(self.name)
	self.name = self:fromIndexValue(indexValue + delta)
end

return SortModel
