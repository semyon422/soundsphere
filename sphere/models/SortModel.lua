local Class = require("aqua.util.Class")

local function sort(...)
	local fields = {...}
	for i, field in ipairs(fields) do
		fields[i] = "noteChartDatas." .. field .. " ASC"
	end
	return table.concat(fields, ",")
end

local SortModel = Class:new()

SortModel.getSortFunction = function(self)
	return self.sortItemsFunctions[self.name]
end

SortModel.sortItemsFunctions = {
	id = sort("id"),
	title = sort("title", "artist", "creator", "inputMode", "difficulty", "name", "id"),
	artist = sort("artist", "title", "creator", "inputMode", "difficulty", "name", "id"),
	difficulty = sort("difficulty", "name", "id"),
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
